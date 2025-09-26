
module Diffusion_Model
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

end module Diffusion_Model


program main_heat
  use cudafor
  use Diffusion_Model
  implicit none
  
  integer :: s, P, Q, i, l, k, ierr
  real(8) :: alpha, dx, dy, dt, total_time, t_start, t_end, dx2, dy2

  real(8), allocatable :: T1(:,:), T2(:,:), W(:,:)
  real(8), allocatable, device :: T1_G(:,:), T2_G(:,:), W_G(:,:)
  real(8), dimension(4) :: bdry

  type(dim3) :: grid, block

    ! Define simple constants
    alpha = 0.000097 ! m^2/s
    s = 3000
    dx = 0.01
    dy = 0.01
    dt = 0.25
    k = 0
    total_time = 0.0

    ! Allocate arrays
    allocate(T1(s+2, s+2))
    allocate(T2(s+2, s+2))
    allocate(W(s+2, s+2))
    allocate(T1_G(s+2, s+2))
    allocate(T2_G(s+2, s+2))
    allocate(W_G(s+2, s+2))


    ! Initial and redefine Temperature, and heat source term
    T2 = 273.15
    W = 0.0
    !W(25,25) = 100.0

    ! Boundary conditions: left, bottom, right, top
    bdry = (/500.0, 200.0, 300.0, 700.0/)
    T2(:,1)   = bdry(1)
    T2(1,:)   = bdry(2)
    T2(:,s+2) = bdry(3)
    T2(s+2,:) = bdry(4)
    T1(:,:)=T2

    ! Calculate values input to kernel
    P = s + 2
    Q = s + 2
    dx2 = 1/(dx*dx)*alpha*dt
    dy2 = 1/(dy*dy)*alpha*dt

    ! copy over device arrays
    T1_G=T1
    T2_G=T2
    W_G=W

    ! Define Grid and Blocks
    grid%x = (P + 15) / 32
    grid%y = (Q + 15) / 32
    grid%z = 1

    block%x = 32
    block%y = 32
    block%z = 1

  ! Launch kernel
  call cpu_time(t_start)
  do l = 1, 5000
    call diffusion<<<grid, block>>>(T1_G, T2_G, W_G, dx2, dy2, P, Q)
      ierr = cudaDeviceSynchronize()
        if (ierr /= 0) then
          print *, 'Error after T1->T2 kernel:', ierr
        end if
    k=k+1
    call diffusion<<<grid, block>>>(T2_G, T1_G, W_G, dx2, dy2, P, Q)
      ierr = cudaDeviceSynchronize()
        if (ierr /= 0) then
          print *, 'Error after T2->T1 kernel:', ierr
        end if
    k=k+1
  end do
  T2=T2_G
  call cpu_time(t_end)
  total_time = t_end - t_start

  print *, 'Total time for 1 runs: ', total_time, ' seconds'
  print *, "Final k value:", k
  !do i = 1, size(T2,1)
    !write(*,'(100f10.4)') T2(i, :)
  !end do


end program main_heat
