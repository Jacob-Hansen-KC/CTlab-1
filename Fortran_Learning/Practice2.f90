

program hello
    implicit none
    integer :: n=1000000,i
    real(8) :: x, fact, k
    x=0
    k=1
    do i=1,n
        fact=1/(i*2.0-1)*k
        k=k*(-1)
       x=x+fact
    end do
    print *, 4*x
end program hello