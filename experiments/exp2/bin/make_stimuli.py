#!/usr/bin/env python3
from datetime import datetime
import sys
import numpy as np

sys.path.append('lib')
from stimulator import Stimulator
from utils import dict_product, Labeler
from define_envs import build

class Stims(Stimulator):
    """Defines conditions and creates stimuli."""
    

    # ---------- Experiment structure ---------- #

    def conditions(self):
        yield {
            'creation_date': str(datetime.now())
        }
    def blocks(self, params):
        yield {
            'block': 'standard',
        }

    def trials(self, params):
        yield {'branch': 3, 'depth': 4, 'first': 'down'}
        # for depth in 
        return
        for d in range(1,6):
            yield {'branch': 2, 'depth': d}
        for d in range(1, 3):
            yield {'branch': 3, 'depth': d}


    # ---------- Create stimuli ---------- #

    def trial(self, params):
        graph, layout = build(**params)
        return {
            'graph': graph,
            'layout': rescale(layout),
            'stateLabels': dict(zip(graph.keys(), graph.keys())),
            'stateDisplay': 'always',
            'edgeDisplay': 'never',
            'initial': '0'
        }


def rescale(layout):
    names, xy = zip(*layout.items())
    x, y = np.array(list(xy)).T
    x -= x.min()
    y -= y.min()
    return dict(zip(names, zip(x.tolist(), y.tolist())))


if __name__ == '__main__':
    Stims().run()

