This example carries out a ParSplice simulation using an inhomogeneous set of replicas. The mapping between MPI ranks and logical worker processes is specific in `input/ps-config.xml`.

```
<Placement>

<Type> Inhomogeneous </Type>
<RanksPerNode> 60 </RanksPerNode>
<TemplatesPerManager> 20 </TemplatesPerManager>

<Groups>
<Group>
<Flavor> 1 </Flavor>
<Ranks> 0  </Ranks>
<Accelerators> 0  </Accelerators>
</Group>

<Group>
<Flavor> 1 </Flavor>
<Ranks> 1  </Ranks>
<Accelerators> 1 </Accelerators>
</Group>

<Group>
<Flavor> 1 </Flavor>
<Ranks> 2 </Ranks>
<Accelerators> 2 </Accelerators>
</Group>

<Group>
<Flavor> 1 </Flavor>
<Ranks> 3 </Ranks>
<Accelerators> 3 </Accelerators>
</Group>

<Group>
<Flavor> 0 </Flavor>
<Ranks>  4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63  </Ranks>
<Accelerators> -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 </Accelerators>
</Group>

</Groups>
```

This calculation is setup for Perlmutter using 64 ranks and 4 GPUs per node. On each node, 5 workers are defined: 4 of them each using 1 MPI rank and 1 GPU, and 1 using the remaining 60 ranks. A new work manager process will be created for every 20 instances of this template. Note that other management processes are required (master process, persistent database, in-memory database, at least 1 work manager), so at least 5 nodes are required to run this example. The included `sub.slurm` file is setup for 10 nodes (640 ranks). The job can be scaled up indefinitely by increasing the number of ranks by increments of 64. The run time is set to 10 minutes, as controlled by the `<RunTime> 10 </RunTime>` entry in `input/ps-config.xml`.

