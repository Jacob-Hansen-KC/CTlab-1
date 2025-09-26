Module Eular_Int
    implicit none

contains
function Eular(f,dx,x1) result(x2)
    real(8), intent(in) :: f(:)
    real(8), intent(in) :: dx, x1
    real(8) :: total=0
    real(8) :: x2
    integer :: i
    print *,size(f)
    do i=1,size(f)
        total=total+(x1**(size(f)-i))*f(i)
        print *, total
    end do
    x2=(total)*dx+x1
end function Eular

end module Eular_int