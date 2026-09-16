import streamlit as st

from modelo_evaporacion import calcular_evaporacion

st.set_page_config(
    page_title="Evaporacion Ven Te Chow",
    layout="wide"
)


st.title("💧 Evaporacion Ven Te Chow")

st.write(
"""
Aplicativo hidrologico basado en el metodo combinado
de Ven Te Chow.

El modelo integra:
- Radiacion disponible
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

    if st.button("Calcular evaporacion"):


        resultado=calcular_evaporacion(
            archivo
        )


        st.success(
            "Calculo realizado correctamente"
        )


        col1,col2,col3=st.columns(3)


        col1.metric(
            "Evaporacion final",
            f"{resultado['evap']:.3f} mm/dia"
        )


        col2.metric(
            "Radiacion extraterrestre",
            f"{resultado['rad']:.3f}"
        )


        col3.metric(
            "Deficit vapor",
            f"{resultado['def']:.3f} KPa"
        )



        st.divider()


        st.subheader(
            "Resultados del modelo"
        )


        st.dataframe(
            resultado["tabla"],
            use_container_width=True
        )



        st.divider()


        st.subheader(
            "Graficos hidrologicos"
        )


        tab1,tab2,tab3=st.tabs(
            [
            "Radiacion",
            "Temperatura",
            "Evaporacion"
            ]
        )


        with tab1:
            st.plotly_chart(
                resultado["graf_rad"],
                use_container_width=True
            )


        with tab2:
            st.plotly_chart(
                resultado["graf_temp"],
                use_container_width=True
            )


        with tab3:
            st.plotly_chart(
                resultado["graf_evap"],
                use_container_width=True
            )
