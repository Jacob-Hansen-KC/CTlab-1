Program Test
    use eular_int
    implicit none
    integer :: i
    real(8) :: x, dx, f(3)
    
    f = [1,0,0]
    dx=0.01
    x=0

    do i=1,10
    x=Eular(f,dx,x)
    print *, x
    end do
    print *, x
end Program test