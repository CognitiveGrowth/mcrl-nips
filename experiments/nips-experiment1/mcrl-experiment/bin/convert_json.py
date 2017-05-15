#!/usr/bin/env python

import json
import time
import itertools as it
import sys





def parse_state(s):
    name = s['nr']
    actions = {}
    sa = s['actions']
    if not isinstance(sa, list):
        sa = [sa]
    for a in sa:
        d = a['direction']
        actions[d] = [a['state'], a['reward']]
    
    x, y = s['location']
    y *= -1
    x += 2
    y += 2
    state = {
        'actions': actions,
        'location': [x, y],
        'reward': s['reward'],
        'path': s['path'],
        
    }
    return (name, state)

def parse_states(ss):
    return dict(map(parse_state, ss))

def parse_trial(t, i):
    return {
        'trialID': i,
        'initialState': 1,
        'graph': parse_states(t['states'][0])
    }

def dict_product(d):
    """All possible combinations of values in lists in `d`"""
    for k, v in d.items():
        if not isinstance(v, list):
            d[k] = [v]

    for v in list(it.product(*d.values())):
        yield dict(zip(d.keys(), v))

def conditions(exp):
    if exp == 2:
        ivs = {
            'feedback': [False, True],
            'break_duration': [0, 10],
        }
        return dict(enumerate(dict_product(ivs)))
    else:
        return {}



def main():
    exp = int(sys.argv[1])
    infile = {
        1: 'MouselabMDPControlExperiment.json',
        2: 'RetentionExperiment.json',
    }[exp]
    outfile = 'exp{}/static/json/condition_1.json'.format(exp)

    with open(infile) as f:
        print('reading', infile)
        inson = json.load(f)
        
        with open(outfile, 'w+') as f:
            condition = {
                'trials': [parse_trial(t, i) for i, t in enumerate(inson)],
                'params': {
                    'creationDate': time.strftime('%c'),
                    'conditions': conditions(exp)
                }
            }
            json.dump(condition, f)
            print('wrote', outfile)

if __name__ == '__main__':
    main()

