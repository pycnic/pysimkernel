# Hierarchichal Design Overview

# User Story 1: Scaling of Basin of attraction volumes for Kuramoto Networks
## Setting: 
A Kuramoto network $$F$$ is completely specified by it's graph topology $$G(V, E)$$ and its set of natural frequencies $$\vec{\omega})$$ for all the nodes. Here we are only intersted in ring topology. All fixed points of a Kuramoto ring are uniquely identified by an integer called the **winding number** $$k$$. 

## Study:
We are interested in the probability that a random initial condition evolves to the steady state with $$k = k'$$, i.e. $$V_{k, N} = P(k | len(V) = N)$$. And we want this over all possible distributions of natural frequencies $\vec{\omega}$ (subject to some constraints, that make it a finite space). 

## Sequential pseudocode would be:
```python
N_range = np.arange(10,100)
V = []

# Outermost loop: obver many ring sizes
for N in N_range:
    V_N = 0
    # loop over all omega combinations
    V_array = []
    for idx, omega in enumerate(all_omegas(N)):
        # loop over many initial conditions
        k_list = []
        for initcond in get_initconds(num_initconds):
            k = find_k(N, omega, initcond)
            k_list.append(k) 
        # Now bin the data to find the frequencies
        V_omega = scipy.stats.itemfreq(k_list)
        V_array.append(V_omega)
    # Do the averaging over all omegas
    V_N = np.average(V_array, axis = 2)
    V.append(V_N)
```

## Can we transform this to this?
```python
basin_singlering = Experiment(find_k, initcond_range = initcond_iter(...), aggregator =\
                                <#something that counts final states and computes probabilities>)
# outout is of the form: {0: 0.78, 1: 0.11, -1: 0.14}
basin_all_omegas_for_single_size = Experiment(basin_singlering, omega_range = omega_iter(100),\
                                             aggregator = <#averages over all omega distributions,\
                                             computes some sort of central tendency>)
# outout is of the form: {'averages': {0: 0.78, 1: 0.11, -1: 0.14}, 'variances': {0: 0.1, 1: 0.2, -1:0.3}
basin_scaling_with_size = Experiment(basin_all_omegas_for_single_size, n_range \=
                                     np.arange(1, 100, 10), aggregator = <# concatenates results for all n>)
# outout is of the form: {n0: {'averages': {}, 'variances': {}}, n1: {'averages': {}, 'variances': {}}, ....}
```

### Advantages:
-  Completely Hierarchichal

### Disadvantages:
-  Fill it in!

## Design idea:
Here I outline how to acheive the user interface that I outlined in the last subsection. 
So here I present a code snippet.

### Disclaimer: 
#### What these code snippets are:
1.  A *minimum working example (MWA)* that is capable of supporting a hierarchichal user interface. 
2.  I do this by writing some classes and their attributes and methods. 
3.  Everything apart from the object structures (classes) and call signature (functions) are demonstrative only.  

#### What they are NOT:
1. Taking into account the whole problem of scheduling. 
2. The aspect of chunking and parallelizing. 

```python
class Experiment(object):
"""
Experiment
=========
An object that specifies how to compute a function *func* on a range of *arguments* and process
all the outputs  from single runs to compute an *output*. 

Parameters
----------
func :  a function/callable
        func must take a single argument that we call *input*
param : a parameter that, along with the function, completely specifies what the *output*
            should be.
input_generator :
        a callable taking a mandatoryargument, *parameter*, that generates the range of *inputs*
        to *func*. it can also take optional parameters. See draft implementation of *run* below. 
"""
    def __init__(self, func, input_generator, input_generator_args = None):
        """
        """
        pass
    def run(self, param):
        """
        """
        return [func(input) for input in input_generator(param, *input_generator_args)]
```

## Design used in test case: basin volume of Kuramoto rings
Let me try to make it clearer by giving an example use case, our very own problem of Kuramoto networks. 
```python
def compute_k((omega, initcond)):
    """Evolves a ring network with frequencies *omega* from initial condition
    *initcond*
    Returns winding number of final state k
    """
    pass

def generate_initconds(omega, nrepeat):
    """generates nrepeat vectors of random phase angles, each same size as omega"""
    for initcond in np.random.uniform(0, 2*np.pi, size = (nrepeat, len(omega))):
        yield omega, initcond

def gen_all_vectors_with_len(len):
    """
    Generates all vectors with elements ±1 and length len
    """
    pass
    
# Experiment that computes the basin volumes of a single ring. Note how teh number of initial conditions is specified as input_generator_args. 
E_onering = Experiment(compute_k, input_generator=\
                        generate_initconds, input_generator_args = (1000,)) 

# Experiment that computes the basin volumes of all rings of a given size
E_onesize = Experiment(E_onering.run, input_generator=\
                        gen_allvectors_with_len, input_generator_args = None)

# Experiment that computes the basin volumes of rings of size in certain range
E_basin_scaling = Experiment(E_onesize.run, input_generator = lambda x:x)
# Finally, call the run function of E_basin_scaling causes all child experiments to run recursively. 
E_basin_scaling.run(param = np.arange(min_size, max_size, 10))
```
OK. So this design can do hierarchical experiments. But let's see how it works in some other scenario, for sake of being thorough:

## Design used in another test case: find out the critical coupling of a kuramoto network
```python
def order_param(Network, initcond):
    """Computes the order parameter by simulating the network from given initial condition"""
    pass
def generate_initconds(nrepeat):
    """
    generates args for func:`order_param`
    """
    
    G = nx.Graph()
    # code to set up your graph here
    for thetas in np.random.uniform(0, 2*pi, size = nrepeat):
        yield G, thetas
E_one_k = Experiment(order_param, input_generator = generate_initconds, input_generator_args = (1000,))
E_orderparam_scaling = Experiment(E_one_k.run, input_generator =\
                                lambda mink, maxk: np.arange(mink, maxk, (maxk - mink)/100))
E_orderparam_scaling.run((0, 1))
```

## Problems:
1. It is plain ugly how we [link text](#abcd). 


