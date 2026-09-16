import pandas as pd
import numpy as np
import plotly.express as px

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

    temp=float(datos.iloc[0,8])
    Tmin=float(datos.iloc[0,10])
    Tmax=float(datos.iloc[0,11])

    hr=float(datos.iloc[0,14])
    vv=float(datos.iloc[0,15])


    #----------------------------
    # Calculo astronomico
    #----------------------------

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
        ang*np.sin(lat_rad)*np.sin(dec)
        +
        np.cos(lat_rad)*np.cos(dec)*np.sin(ang)
    )


    #----------------------------
    # Energia
    #----------------------------

    factor=2.501-0.002361*temp

    Rn_mmxd=Rn/factor


    #----------------------------
    # Deficit vapor
    #----------------------------

    def_vapor=(
        ((Pr_vap_sat(Tmax)+Pr_vap_sat(Tmin))*0.5*
        (1-hr/100))/10
    )


    #----------------------------
    # Evaporacion
    #----------------------------

    patm=101.3*((293-0.0065*alt)/293)**5.256

    cpsi=(0.0016286*patm)/factor

    delta=(4098*(Pr_vap_sat(temp)/10))/(237.3+temp)**2

    c1=delta/(delta+cpsi)

    c2=(cpsi/(delta+cpsi))*(6.43*(1+0.536*vv))/factor


    aporte_energia=c1*Rn_mmxd/factor

    aporte_aero=c2*def_vapor

    evap=aporte_energia+aporte_aero



    #----------------------------
    # Tabla resultados
    #----------------------------

    tabla=pd.DataFrame({

        "Parametro":[
            "Radiacion extraterrestre",
            "Radiacion neta",
            "Deficit vapor",
            "Aporte energia",
            "Aporte aerodinamico",
            "Evaporacion final"
        ],

        "Valor":[
            rad_ext,
            Rn_mmxd,
            def_vapor,
            aporte_energia,
            aporte_aero,
            evap
        ],

        "Unidad":[
            "MJ/m2/dia",
            "mm/dia",
            "KPa",
            "mm/dia",
            "mm/dia",
            "mm/dia"
        ],

        "Descripcion":[

            "Energia solar disponible calculada mediante posicion solar.",

            "Energia disponible para producir evaporacion.",

            "Capacidad atmosferica para absorber humedad.",

            "Efecto de la energia sobre la evaporacion.",

            "Influencia del viento y condiciones atmosfericas.",

            "Evaporacion diaria estimada por Ven Te Chow."
        ]

    })


    #----------------------------
    # Graficos
    #----------------------------


    graf_rad=pd.DataFrame({

        "Variable":[
            "Radiacion extraterrestre",
            "Radiacion neta"
        ],

        "Valor":[
            rad_ext,
            Rn_mmxd
        ]

    })


    fig_rad=px.bar(
        graf_rad,
        x="Variable",
        y="Valor",
        title="Balance de Radiacion"
    )



    graf_temp=pd.DataFrame({

        "Variable":[
            "Tmin",
            "Tmedia",
            "Tmax"
        ],

        "Valor":[
            Tmin,
            temp,
            Tmax
        ]

    })


    fig_temp=px.line(
        graf_temp,
        x="Variable",
        y="Valor",
        markers=True,
        title="Variables Termicas"
    )



    graf_evap=pd.DataFrame({

        "Variable":[
            "Energia",
            "Aerodinamico",
            "Total"
        ],

        "Valor":[
            aporte_energia,
            aporte_aero,
            evap
        ]

    })


    fig_evap=px.bar(
        graf_evap,
        x="Variable",
        y="Valor",
        title="Componentes de Evaporacion"
    )


    return {

        "tabla":tabla,

        "evap":evap,

        "rad":rad_ext,

        "def":def_vapor,

        "graf_rad":fig_rad,

        "graf_temp":fig_temp,

        "graf_evap":fig_evap

    }
