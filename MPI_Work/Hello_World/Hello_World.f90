! filepath: /home/j221h043/work/Hello_World.f90
program Hello_World
  use mpi_f08
  implicit none

  integer Rank, size_Of_Cluster, ierror

  call MPI_INIT(ierror)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, size_Of_Cluster, ierror)
  call MPI_COMM_RANK(MPI_COMM_WORLD, Rank, ierror)

  print *, 'Hello World from process: ', Rank, 'of ', size_Of_Cluster

  call MPI_FINALIZE(ierror)
end program Hello_World