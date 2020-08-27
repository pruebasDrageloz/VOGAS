import numpy as np
import matplotlib.pyplot as plt
def exact_feature(cj,this_sensor,this_feature):

    if(not this_sensor):
        this_sensor = 'GNP'

    if(not this_feature):
        this_sensor = 'mean_last_5'

    x = np.ones((1,8))
    x[:] = np.nan
    tmp = cj['Flow']
    iic = 1
    if(this_sensor in cj.keys()):
        tmp = cj[f'{this_sensor}']
        tmp['x'] = np.array(tmp['x'])/np.array(np.ones((len(tmp['x']),1))*tmp['baseline'])
        if(this_feature == 'mean_last_5'):
            inds = np.where(tmp['t'] >= max(tmp['t'])-5)
            x = np.mean(tmp['x'][inds,:], axis=1)
        else:
            #error('no such feature')
            pass
    return(x)