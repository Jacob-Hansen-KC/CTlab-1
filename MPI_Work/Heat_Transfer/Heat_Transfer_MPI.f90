! filepath: c:\Users\Jacob\Python\heat_equation.f90
program main_heat
  use mpi_f08
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  integer :: s, P, Q, i, j, k, run, l, io
  real(dp) :: alpha, dx, dy, dt, total_time, t_start, t_end
  real(dp), allocatable :: T1(:,:), T2(:,:), W(:,:)
  real(dp), dimension(4) :: bdry
  real(dp) :: dx2, dy2
  integer :: Rank, size_Of_Cluster, ierror
  integer :: sy_local, sy_halo
  real(dp), allocatable :: Left_Halo(:), Right_Halo(:)
  real(dp), allocatable :: tempL(:), tempR(:)
  real(dp), allocatable :: WholeT(:,:)

  call MPI_INIT(ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size_Of_Cluster, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, Rank, ierror)

  total_time = 0.0_dp

    ! Define simple constants
    alpha = 0.000097_dp ! m^2/s
    s = 50
    dx = 0.01_dp
    dy = 0.01_dp
    dt = 0.25_dp

    ! Allocate arrays
    allocate(WholeT(s+2, s+2))
    allocate(W(s+2, s+2))

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
    allocate(TempL(Q))
    allocate(TempR(Q))

    ! Allocate Device Arrays
    allocate(T1(P, Q))
    allocate(T2(P, Q))

    ! Initial and redefine Temperature, and heat source term
    WholeT = 273.15_dp
    T1 = 0.0_dp
    W = 0.0_dp
    !W(25,25) = 100.0_dp

    ! Boundary conditions: left, bottom, right, top
    bdry = (/500.0_dp, 200.0_dp, 300.0_dp, 700.0_dp/)
    WholeT(:,1)   = bdry(1)
    WholeT(1,:)   = bdry(2)
    WholeT(:,s+2) = bdry(3)
    WholeT(s+2,:) = bdry(4)

if (rank==0) then
  T2=WholeT(1:sy_halo,1:Q)
  print *, "Sectioned"
  end if
if (rank==1) then
  T2=WholeT(1:Q,sy_local:Q)
  print *, "sectioned"
  end if

    k = 0
    if (rank==0) then
    call cpu_time(t_start)
    end if
    T1(:,:)=T2
    print *, "Start Loop"
    do l = 1, 5
      do j = 2, Q-1
        do i = 2, P-1
          T2(i,j) = T1(i,j) + ( (T1(i+1,j) - 2.0_dp*T1(i,j) + T1(i-1,j))*(dx2) + &
                                           (T1(i,j+1) - 2.0_dp*T1(i,j) + T1(i,j-1))*(dy2) ) + W(i,j)*dt
        end do
      end do

if (Rank == 0) then
    TempL=T2(sy_halo,:)
    call MPI_SEND(TempL,Q,MPI_REAL8,1,1,MPI_COMM_WORLD,ierror)
end if

if (Rank == 1) then 
    call MPI_RECV(Right_Halo,Q,MPI_REAL8,0,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
end if


if (Rank == 1) then
    TempR=T2(1,:)
    call MPI_SEND(TempR,Q,MPI_REAL8,0,1,MPI_COMM_WORLD,ierror)
end if

if (Rank == 0) then 
    call MPI_RECV(Left_Halo,Q,MPI_REAL8,1,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
end if

call MPI_BARRIER( MPI_COMM_WORLD, ierror)

if (Rank == 0) then
    T2(end,:)=Left_Halo
  end if
if (Rank == 1) then
    T2(1,:)=Right_Halo
end if

      k = k + 1
        do j = 2, Q-1
          do i = 2, P-1
            T1(i,j) = T2(i,j) + ( (T2(i+1,j) - 2.0_dp*T2(i,j) + T2(i-1,j))*(dx2) + &
                                           (T2(i,j+1) - 2.0_dp*T2(i,j) + T2(i,j-1))*(dy2) ) + W(i,j)*dt
          end do
        end do

if (Rank == 0) then
    TempL=T2(sy_halo,:)
    call MPI_SEND(TempL,Q,MPI_REAL8,1,1,MPI_COMM_WORLD,ierror)
end if

if (Rank == 1) then 
    call MPI_RECV(Right_Halo,Q,MPI_REAL8,0,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
end if


if (Rank == 1) then
    TempR=T2(1,:)
    call MPI_SEND(TempR,Q,MPI_REAL8,0,1,MPI_COMM_WORLD,ierror)
end if

if (Rank == 0) then 
    call MPI_RECV(Left_Halo,Q,MPI_REAL8,1,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
end if

call MPI_BARRIER( MPI_COMM_WORLD, ierror)

if (Rank == 0) then
    T1(end,:)=Left_Halo
  end if
if (Rank == 1) then
    T1(1,:)=Right_Halo
end if

      k = k + 1
    end do
  print *, "end Loop"
  if (Rank == 1) then
  end if
  if (Rank == 0) then
  call cpu_time(t_end)
  total_time = t_end - t_start
  print *, 'Total time for 1 runs: ', total_time, ' seconds'
  print *, 'Number of iterations: ', k
  do i = 1, size(T2,1)
    write(*,'(100f10.4)') T2(:, i)
  end do
  end if
end program main_heat