! filepath: c:\Users\Jacob\Python\heat_equation.f90
program heat_equation
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  integer :: s, P, Q, i, j, k, run
  real(dp) :: a, alpha, dx, dy, dt, value, total_time, t_start, t_end
  real(dp), allocatable :: T1(:,:), T2(:,:), W(:,:)
  real(dp), dimension(4) :: bdry
  real(dp) :: dx2, dy2

  !call cpu_time(t_start)
  total_time = 0.0_dp

  do run = 1, 1
    ! Define simple constants
    a = 97.0_dp
    alpha = a / (1000.0_dp**2)
    s = 100
    dx = 0.01_dp
    dy = 0.01_dp
    dt = 0.25_dp

    ! Allocate arrays
    allocate(T1(s+2, s+2))
    allocate(T2(s+2, s+2))
    allocate(W(s+2, s+2))

    ! Initial and redefine Temperature, and heat source term
    T2 = 273.15_dp
    T1 = 0.0_dp
    W = 0.0_dp
    W(25,25) = 100.0_dp

    ! Boundary conditions: left, bottom, right, top
    bdry = (/500.0_dp, 200.0_dp, 300.0_dp, 700.0_dp/)
    T2(:,1)   = bdry(1)
    T2(1,:)   = bdry(2)
    T2(:,s+2) = bdry(3)
    T2(s+2,:) = bdry(4)

    k = 0
    value = 1.0_dp
    P = s + 2
    Q = s + 2

    ! Main iteration loop
    dx2 = dx*dx
    dy2 = dy*dy
    do while (value > 0.005_dp)
      T1 = T2
      do j = 2, Q-1
        do i = 2, P-1
          T2(i,j) = T1(i,j) + alpha*dt * ( (T1(i+1,j) - 2.0_dp*T1(i,j) + T1(i-1,j))/(dx2) + &
                                           (T1(i,j+1) - 2.0_dp*T1(i,j) + T1(i,j-1))/(dy2) ) + W(i,j)*dt
        end do
      end do
      k = k + 1
      ! Reapply boundary conditions
      T2(:,1)   = bdry(1)
      T2(1,:)   = bdry(2)
      T2(:,s+2) = bdry(3)
      T2(s+2,:) = bdry(4)
      value = abs(sum(T2 - T1) / real(P*Q, dp))
    end do

    deallocate(T1, T2, W)
  end do

  !call cpu_time(t_end)
  !total_time = t_end - t_start
  !print *, 'Total time for 1 runs: ', total_time, ' seconds'
  print *, 'Number of iterations: ', k
end program heat_equation

!gfortran C:\Users\Jacob\Python\heat_equation.f90 -o heat_equation.exe 
!.\heat_equation.exe
