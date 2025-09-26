program HelloWorld
  use openacc
  implicit none
  integer, parameter :: N=1024
  integer :: i

!$acc parallel loop vector_length(256) gang num_gangs(N/256)
  do i = 1, N
    print *, "hello world", i
  end do
!$acc end parallel loop

end program HelloWorld