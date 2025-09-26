! filepath: /home/j221h043/work/Juggling.f90
program Juggling
  use mpi_f08
  implicit none

    integer :: Rank, size_Of_Cluster, ierror
    integer :: k, float, Alpha=0, Beta=0 ,Gamma=0, Delta=0, i
    integer :: a(5), b(5), c(5), d(5)
    i=5

    call MPI_INIT(ierror)

    call MPI_COMM_SIZE(MPI_COMM_WORLD, size_Of_Cluster, ierror)
    call MPI_COMM_RANK(MPI_COMM_WORLD, Rank, ierror)

if (Rank == 0) then
    Alpha=10
    Beta=20
end if

if (Rank == 1) then
    Gamma=30
    Delta=40
end if

do k=1,5

    if (Rank==0) then  
    call MPI_SEND(Beta,1,MPI_INT,1,1,MPI_COMM_WORLD,ierror)
    end if

    if (Rank==1) then
    call MPI_RECV(float,1,MPI_INT,0,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
    end if

    if (Rank==1) then
    call MPI_SEND(Delta,1,MPI_INT,0,1,MPI_COMM_WORLD,ierror)
    end if

    if (Rank==0) then  
    call MPI_RECV(float,1,MPI_INT,1,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
    end if

    call MPI_BARRIER( MPI_COMM_WORLD, ierror)

    if (Rank==0) then
    Beta=Alpha
    Alpha=float
    a(k)=Alpha
    b(k)=Beta
    end if

    if (Rank==1) then
    Delta=Gamma
    Gamma=float
    c(k)=Gamma
    d(k)=Delta
    end if

    call MPI_BARRIER( MPI_COMM_WORLD, ierror)

end do

    if (Rank==1) then  
    call MPI_SEND(d,i,MPI_INT,0,1,MPI_COMM_WORLD,ierror)
    end if

    if (Rank==1) then
    call MPI_SEND(c,i,MPI_INT,0,1,MPI_COMM_WORLD,ierror)
    end if

    call MPI_BARRIER( MPI_COMM_WORLD, ierror)

     if (Rank==0) then
    call MPI_RECV(d,i,MPI_INT,1,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
    end if

    if (Rank==0) then  
    call MPI_RECV(c,i,MPI_INT,1,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE,ierror)
    end if

 if (Rank==0) then
  do k=1,5
  print *, a(k),b(k)
  print *, c(k),d(k)
  print *, ""
  end do
end if

    call MPI_FINALIZE(ierror)
end program Juggling