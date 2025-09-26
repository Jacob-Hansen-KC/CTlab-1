
module Diffusion_Model_2
use cudafor
implicit none
  contains

  attributes(global) & 
  subroutine diffusion(T1, T2, W, dx2, dy2, P, Q)
    implicit none
    integer, value :: P, Q
    real(8), value :: dx2, dy2
    real(8), device :: T1(P,Q), T2(P,Q), W(P,Q)
    integer :: i, j
    real(8) :: dt = 0.25

    i = threadIdx%x + (blockIdx%x - 1) * blockDim%x
    j = threadIdx%y + (blockIdx%y - 1) * blockDim%y
  if (i > P .or. j > Q) return
    if (i >= 2 .and. i <= P-1 .and. j >= 2 .and. j <= Q-1) then
        T2(i,j) = T1(i,j) + ((T1(i+1,j) - 2.0*T1(i,j) + T1(i-1,j)) * dx2 + &
                             (T1(i,j+1) - 2.0*T1(i,j) + T1(i,j-1)) * dy2) + W(i,j) * dt
        call syncthreads()
    end if
  end subroutine diffusion

end module Diffusion_Model_2


program main_heat
  use cudafor
  use Diffusion_Model_2
  use mpi
  implicit none
  
  integer :: s, P, Q, i, l, k
  real(8) :: alpha, dx = 0.01, dy = 0.01 , dt = 0.25, total_time, t_start, t_end, dx2, dy2
  real(8), allocatable :: T1(:,:), T2(:,:), W(:,:)
  real(8), dimension(4) :: bdry

  integer ::  ierr, rank, npr, dev
  real(8), allocatable, device :: T1_G(:,:), T2_G(:,:), W_G(:,:)
  type(dim3) :: grid, block
  integer :: sy_local, sy_halo
  real(8), allocatable :: Left_Halo(:), Right_Halo(:)
  real(8), allocatable :: tmp(:,:), tmp2(:)

    ! Define simple constants
    alpha = 0.000097 ! m^2/s
    s = 50
    k = 0
    total_time = 0.0

    ! Initialize Partition things
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, npr, ierr)
    ierr = cudaSetDevice(rank)


    ! Allocate arrays
    allocate(T1(s+2, s+2))
    allocate(T2(s+2, s+2))
    allocate(W(s+2, s+2))

    ! Initial and redefine Temperature, and heat source term
    T2 = 273.15
    W = 0.0
    !W(25,25) = 100.0

    ! Boundary conditions: left, bottom, right, top
    bdry = (/500.0, 200.0, 300.0, 700.0/)
    T2(:,1)   = bdry(1)
    T2(:,s+2) = bdry(3)
    T2(1,:)   = bdry(2)
    T2(s+2,:) = bdry(4)
    T1(:,:)=T2

    ! Calculate values input to kernel
    sy_local=(s+2)/2
    sy_halo = sy_local + 1
    P = sy_halo
    Q = s + 2
    dx2 = 1/(dx*dx)*alpha*dt
    dy2 = 1/(dy*dy)*alpha*dt
    
    ! Allocate Halo Arrays
    allocate(Left_Halo(Q))
    allocate(Right_Halo(Q))

    ! Allocate Device Arrays
    allocate(T1_G(P, Q))
    allocate(T2_G(P, Q))
    allocate(W_G(P, Q))
    ! Copy updated T to device 
    
    ! First 27 rows
    if (rank == 0) then
      allocate(tmp(P,Q))
      tmp = T1(1:P,1:Q)
      print *, sizeof(real(8))
      ierr = cudaMemcpy(T1_G, tmp, "P*Q*sizeof(real(8))", cudaMemcpyHostToDevice)
      T2_G=T1_G
    end if
    if (ierr /= 0) then
      print *, "CUDA error code:", ierr, 'line 106'
    end if

    ! last 27 rows
    if (rank == 1) then
      allocate(tmp(P,Q))
      tmp = T1(P-1:P*2-2, 1:Q)
      ierr = cudaMemcpy(T1_G, tmp, 1, cudaMemcpyHostToDevice)
      T2_G=T1_G
    end if
    if (ierr /= 0) then
      print *, "CUDA error code:", ierr, 'line 117'
    end if


    W_G=W

  ! Define blocks and grid
  block%x = 16
  block%y = 16
  grid%x = (P + block%x - 1) / block%x
  grid%y = (Q + block%y - 1) / block%y

  ! Launch kernel
  call cpu_time(t_start)
  do l = 1, 5000

  ! Halo exchange
    ! Copy halos from device
    allocate(tmp2(Q))
    tmp2 = T1_G(sy_halo,:)
    ierr = cudaMemcpy(left_halo, tmp2, Q*8, cudaMemcpyDeviceToHost)

    if (ierr /= 0) then
      print *, "CUDA error code:", ierr, 'line 140'
    end if

    tmp2 = T1_G(1,:)
    ierr = cudaMemcpy(right_halo, tmp2, Q*8, cudaMemcpyDeviceToHost)

    if (ierr /= 0) then
      print *, "CUDA error code:", ierr, 'line 147'
    end if

    ! Send/Receive
    if (rank == 0) then
      call MPI_Sendrecv(left_halo, Q, MPI_DOUBLE_PRECISION, 1, 0, &
                        T1(s/2:s/2,1), Q, MPI_DOUBLE_PRECISION, 1, 1, &
                        MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
    end if

    if (rank == 1) then
      call MPI_Sendrecv(right_halo, Q, MPI_DOUBLE_PRECISION, 1, 0, &
                        T1((s/2)+1:(s/2)+1,1), Q, MPI_DOUBLE_PRECISION, 0, 0, &
                        MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
    end if

    ! Copy updated halo to device
    if (rank == 0) then
      tmp2=T1(P+1,:)
      ierr = cudaMemcpy(T1_G(P,:), tmp2, Q*8, cudaMemcpyHostToDevice)
    end if

    if (rank == 1) then
      tmp2=T1(P,:)
      ierr = cudaMemcpy(T1_G(1,:), tmp2, Q*8, cudaMemcpyHostToDevice)
    end if

    if (ierr /= 0) then
      print *, "CUDA error code:", ierr, 'line 175'
    end if

    T2_G=T1_G

    call diffusion<<<grid, block>>>(T1_G, T2_G, W_G, dx2, dy2, P, Q)
      ierr = cudaDeviceSynchronize()
        if (ierr /= 0) then
          print *, 'Error after T1->T2 kernel:', ierr, 'line 183'
        end if
    k=k+1
    call diffusion<<<grid, block>>>(T2_G, T1_G, W_G, dx2, dy2, P, Q)
      ierr = cudaDeviceSynchronize()
        if (ierr /= 0) then
          print *, 'Error after T2->T1 kernel:', ierr, 'line 189'
        end if
    k=k+1
  end do


  T2=T2_G
  call cpu_time(t_end)
  total_time = t_end - t_start

  if (rank == 0) print *, 'Total time for run: ', total_time, ' seconds'
  print *, "Final k value:", k
  !do i = 1, size(T2,1)
    !write(*,'(100f10.4)') T2(i, :)
  !end do

  call MPI_Finalize(ierr)
end program main_heat
