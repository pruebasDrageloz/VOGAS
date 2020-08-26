import numpy as np
import json


#Clase encargada de leer el archivo json y obtener la información de sus valores principales
class jsonLab_readVolgacore():
    def __init__(self):
        self.inicio = "inicio"

    def read(self, path):
        
        with open(path, 'r') as myfile:
            cj=json.load(myfile)

        ###inicio de proyecto a convertir
        ## Se agregan a cj los valores del archivo json que se utilizaran en el código
        cj['parameters'] = cj['measurements'][0]['devices'][0]['parameters']
        cj['t0'] = np.nan

        #Se recorren los dispositivos y se extrae la información de Flow, GNP, MOX ANALOG y MOX DIGITAL
        for iis in range(len(cj['measurements'][0]['devices'][0]['devices'])): 
            devname0 = cj['measurements'][0]['devices'][0]['devices'][iis]['name']
            tmp = cj['measurements'][0]['devices'][0]['devices'][iis]['sensors']
            if devname0 == 'Flow':
                cj['Flow'] = {}
                devname = devname0
                cj[f'{devname}']['t'] = np.array(tmp['data'])[:,0]*24*3600
                cj[f'{devname}']['x'] = np.array(tmp['data'])[:,1:]
                cj[f'{devname}']['names'] = tmp['names']
            elif devname0 == 'GNP':
                cj['GNP'] = {}
                devname = devname0
                cj[f'{devname}']['t'] = np.array(tmp['data'])[:,0]*24*3600
                cj['t0'] = cj[f'{devname}']['t'][cj['parameters']['BaselineAcqs']]
                cj[f'{devname}']['x'] = np.array(tmp['data'])[:,1:]
                cj[f'{devname}']['names'] = tmp['names']

                
                cj[f'{devname}']['inds'] = np.zeros(len(cj[f'{devname}']['t']))
                cj[f'{devname}']['inds'][cj['parameters']['BaselineAcqs']:] = 1
                cj[f'{devname}']['baseline'] = np.mean(cj[f'{devname}']['x'][1-cj[f'{devname}']['inds'] == 1,:], axis=0)
            elif devname0 == 'MOX analog':
                cj['MOX analog'] = {}
                devname = devname0
                cj[f'{devname}']['t'] = np.array(tmp['data'])[:,0]*24*3600
                cj['t0'] = cj[f'{devname}']['t'][cj['parameters']['BaselineAcqs']]
                cj[f'{devname}']['x'] = np.array(tmp['data'])[:,1:]
                cj[f'{devname}']['names'] = tmp['names']

                
                cj[f'{devname}']['inds'] = np.zeros(len(cj[f'{devname}']['t']))
                cj[f'{devname}']['inds'][cj['parameters']['BaselineAcqs']:] = 1
                cj[f'{devname}']['baseline'] = np.mean(cj[f'{devname}']['x'][1-cj[f'{devname}']['inds'] == 1,:], axis=0)
            elif 'MOX digital':
                cj['MOXdigital'] = {}
                devname = 'MOXdigital'
                cj[f'{devname}']['info'] = 'todo'
            
        return(cj)
            