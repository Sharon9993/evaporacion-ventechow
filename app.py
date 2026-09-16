import streamlit as st

from modelo_evaporacion import calcular_evaporacion


st.title("💧 Evaporación Ven Te Chow")

st.write(
"""
Aplicativo hidrológico basado en el método combinado
de Ven Te Chow.

El modelo calcula la evaporación diaria considerando:
- Radiación disponible
- Temperatura
- Humedad relativa
- Velocidad del viento
"""
)


archivo=st.file_uploader(
"Cargar archivo data_evap.xlsx",
type=["xlsx"]
)



if archivo:

    if st.button("Calcular"):


        resultado=calcular_evaporacion(
            archivo
        )


        st.success(
        "Cálculo realizado correctamente"
        )


        col1,col2,col3=st.columns(3)


        col1.metric(
        "Evaporación",
        f"{resultado['evaporacion']:.3f} mm/día"
        )


        col2.metric(
        "Radiación extraterrestre",
        f"{resultado['radiacion']:.3f}"
        )


        col3.metric(
        "Déficit vapor",
        f"{resultado['deficit']:.3f} KPa"
        )
