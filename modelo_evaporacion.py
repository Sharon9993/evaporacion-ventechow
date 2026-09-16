import pandas as pd
import numpy as np


def Pr_vap_sat(T):
    return 6.11*np.exp((17.27*T)/(237.3+T))


def calcular_evaporacion(archivo):

    datos=pd.read_excel(
        archivo,
        header=None
    )


    lat=float(datos.iloc[0,0])
    alt=float(datos.iloc[0,1])

    ano=int(datos.iloc[0,2])
    mes=int(datos.iloc[0,3])
    dia=int(datos.iloc[0,4])

    Rn=float(datos.iloc[0,5])

    temp=float(datos.iloc[0,9])
    Tmin=float(datos.iloc[0,11])
    Tmax=float(datos.iloc[0,12])

    hr=float(datos.iloc[0,14])
    vv=float(datos.iloc[0,15])


    fecha=pd.Timestamp(
        ano,
        mes,
        dia
    )


    nj=fecha.dayofyear


    dec=0.4093*np.sin(
        (2*np.pi*nj/365)-1.405
    )


    lat_rad=lat*np.pi/180


    ang=np.arccos(
        -np.tan(lat_rad)*np.tan(dec)
    )


    rad_ext=15.392*(1+0.033*np.cos(
        2*np.pi*nj/365
    ))*(

    ang*np.sin(lat_rad)*np.sin(dec)+
    np.cos(lat_rad)*np.cos(dec)*np.sin(ang)

    )


    factor=2.501-0.002361*temp


    Rn_mmxd=Rn/factor


    def_vapor=(

    ((Pr_vap_sat(Tmax)+Pr_vap_sat(Tmin))*0.5*
    (1-hr/100))/10

    )


    evap=(
        Rn_mmxd/factor
        +
        def_vapor*(1+0.536*vv)
    )


    return {

        "evaporacion":evap,
        "radiacion":rad_ext,
        "deficit":def_vapor

    }
