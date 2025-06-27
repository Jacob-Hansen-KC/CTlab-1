! filepath: c:\Users\Jacob\Python\heat_equation.f90
program main_heat
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  integer :: s, P, Q, i, j, k, run, l, io
  real(dp) :: alpha, dx, dy, dt, total_time, t_start, t_end
  real(dp), allocatable :: T1(:,:), T2(:,:), W(:,:)
  real(dp), dimension(4) :: bdry
  real(dp) :: dx2, dy2

  call cpu_time(t_start)
  total_time = 0.0_dp

    ! Define simple constants
    alpha = 0.000097_dp ! m^2/s
    s = 600
    dx = 0.01_dp
    dy = 0.01_dp
    dt = 0.25_dp

    ! Allocate arrays
    allocate(T1(s+2, s+2))
    allocate(T2(s+2, s+2))
    allocate(W(s+2, s+2))
    ! tmp does not need allocation

    ! Initial and redefine Temperature, and heat source term
    T2 = 273.15_dp
    T1 = 0.0_dp
    W = 0.0_dp
    !W(25,25) = 100.0_dp

    ! Boundary conditions: left, bottom, right, top
    bdry = (/500.0_dp, 200.0_dp, 300.0_dp, 700.0_dp/)
    T2(:,1)   = bdry(1)
    T2(1,:)   = bdry(2)
    T2(:,s+2) = bdry(3)
    T2(s+2,:) = bdry(4)

    k = 0
    P = s + 2
    Q = s + 2
    dx2 = 1/(dx*dx)
    dy2 = 1/(dy*dy)
    do l = 1, 10000
      T1 = T2
      do j = 2, Q-1
        do i = 2, P-1
          T2(i,j) = T1(i,j) + alpha*dt * ( (T1(i+1,j) - 2.0_dp*T1(i,j) + T1(i-1,j))*(dx2) + &
                                           (T1(i,j+1) - 2.0_dp*T1(i,j) + T1(i,j-1))*(dy2) ) + W(i,j)*dt
        end do
      end do
      k = k + 1
    end do
  call cpu_time(t_end)
  total_time = t_end - t_start
  print *, 'Total time for 1 runs: ', total_time, ' seconds'
  print *, 'Number of iterations: ', k
  !do i = 1, size(T2,1)
    !write(*,'(100f10.2)') T2(i, :)
  !end do
end program main_heat

!.\heat_equation_Fastest.exe
!gfortran -O3 -g -fbacktrace -march=native C:\Users\Jacob\Python\heat_equation_Fastest.f90 -o heat_equation_Fastest.exe