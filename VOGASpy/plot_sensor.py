import matplotlib.pyplot as plt
import numpy as np

def plot_sensor(cj, filename, fig, this_sensor='GNP',this_color=[1,0,0], legend=False):

    plt.subplots_adjust(top=0.92, bottom=0.08, left=0.10, right=0.95, hspace=0.25,
                    wspace=0.35)
    tmp = cj['Flow']
    plt.subplot(3,3,1)
    iic = 0
    plt.plot(tmp['t']-cj['t0'], tmp['x'][:,iic], color=this_color) 
    plt.ylabel('Flow')
    if(this_sensor in cj.keys()):
        tmp = cj[f'{this_sensor}']
        tmp['x'] = np.array(tmp['x'])/np.array(np.ones((len(tmp['x']),1))*tmp['baseline'])
        for iic in range(8):
            plt.subplot(3,3,iic+2)
            plt.plot(tmp['t'][tmp['inds'] == 1]-cj['t0'], tmp['x'][tmp['inds'] == 1,iic], color=this_color, label=filename)
            plt.ylabel('baseline compensated')
            plt.title(str(tmp['names'][iic]))

        if(legend):
            plt.legend(framealpha=1, frameon=True)
        else:
            plt.legend(bbox_to_anchor=(1.05, 3), loc='upper left')
    
        