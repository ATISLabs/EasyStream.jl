using Revise

Pkg.activate(".")

using EasyStream

pool = EasyStream.Dataset1CDT()

pool[150,:]

EasyStream.next!(stream)

stream[1,:]
