#!/usr/bin/env python3
import numpy as np
import itertools as it
from scipy.io import savemat
import os
import json
from collections import defaultdict

# ---------- Constructing environments ---------- #
BRANCH_DIRS = {
    2: {'up': ('right', 'left'),
        'right': ('up', 'down'),
        'down': ('right', 'left'),
        'left': ('up', 'down'),
        'all': ('right', 'left')},
    3: {'up': ('up', 'right', 'left'),
        'right': ('up', 'right', 'down'),
        'down': ('right', 'down', 'left'),
        'left': ('up', 'down', 'left'),
        'all': ('up', 'right', 'down', 'left')}
}

def move_xy(x, y, direction, dist=1):
    return {
        'right': (x+dist, y),
        'left': (x-dist, y),
        'down': (x, y+dist),
        'up': (x, y-dist),
    }.get(direction)


def dist(branch, depth):
    """Distance between nodes at a given depth of a tree with given branching factor."""
    if branch == 3:
        return 2 ** (depth - 1)
    else:
        return 2 ** (depth/2 - 0.5)
    
def build(branch, depth, first='up', **kwargs):
    """Returns graph and layout to be used in Mouselab-MDP."""
    graph = {}
    layout = {}
    names = it.count()
    
    def node(d, x, y, prev_dir):
        r = 0  # reward is 0 for now
        name = str(next(names))
        layout[name] = (x, y)
        graph[name] = {}
        if d > 0:
            for direction in BRANCH_DIRS[branch][prev_dir]:
                x1, y1 = move_xy(x, y, direction, dist(branch, d))
                graph[name][direction] = (r, node(d-1, x1, y1, direction))
                                        
        return name
    
    node(depth, 0, 0, first)
    return graph, layout

# ---------- Information about environments ---------- #

def n_step(graph):
    """Number of steps it takes to reach every state."""
    result = {}
    def search(s, n):
        result[s] = n
        for _, s1 in graph[s].values():
            search(s1, n+1)
    search('0', 0)
    return result

def transition_matrix(graph):
    """X[s0, s1] is 1 if there is an edge from s0 to s1, else 0."""
    X = np.zeros((len(graph), len(graph)))
    for s0, actions in graph.items():
        for _, s1 in actions.values():
            X[int(s0), int(s1)] = 1
    return X

def main():
    transition = {}
    nsteps = defaultdict(dict)
    for branch in (2, 3):
        for depth in range(1, 6):
            graph, layout = build(branch, depth)
            name = 'b{}d{}'.format(branch, depth)
            transition[name] = transition_matrix(graph)
            nsteps[branch][depth] = n_step(graph)
    
    os.makedirs('env_data', exist_ok=True)
    savemat('env_data/transition.mat', mdict=transition)
    with open('experiment/static/json/nsteps.json', 'w+') as f:
        json.dump(nsteps, f)


if __name__ == '__main__':
    main()
