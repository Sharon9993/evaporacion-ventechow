###############################################################
# MODELO EVAPORACION VEN TE CHOW
###############################################################

library(readxl)
library(ggplot2)


Pr_vap_sat <- function(T){
  6.11*exp((17.27*T)/(237.3+T))
}


calcular_evaporacion <- function(archivo){

d <- read_excel(archivo,col_names=FALSE)

lat<-as.numeric(d[1,1]); alt<-as.numeric(d[1,2])
ano<-as.numeric(d[1,3]); mes<-as.numeric(d[1,4]); dia<-as.numeric(d[1,5])
Rn<-as.numeric(d[1,6])
temp<-as.numeric(d[1,9])
Tmin<-as.numeric(d[1,11]); Tmax<-as.numeric(d[1,12])
hr<-as.numeric(d[1,15]); vv<-as.numeric(d[1,16])


# Astronomia

nj<-as.numeric(format(as.Date(paste(ano,mes,dia,sep="-")),"%j"))

dec<-0.4093*sin((2*pi*nj/365)-1.405)
latr<-lat*pi/180
ang<-acos(-tan(latr)*tan(dec))

rad_ext<-15.392*(1+0.033*cos(2*pi*nj/365))*
(ang*sin(latr)*sin(dec)+cos(latr)*cos(dec)*sin(ang))


# Energia y deficit

ft<-2.501-0.002361*temp

Rn_mmxd<-Rn/ft

def_vapor<-((Pr_vap_sat(Tmax)+Pr_vap_sat(Tmin))*0.5*
(1-hr/100))/10


# Evaporacion

patm<-101.3*((293-0.0065*alt)/293)^5.256

cpsi<-(0.0016286*patm)/ft

delta<-(4098*(Pr_vap_sat(temp)/10))/(237.3+temp)^2

c1<-delta/(delta+cpsi)

c2<-(cpsi/(delta+cpsi))*(6.43*(1+0.536*vv))/ft

aporte_energia<-c1*Rn_mmxd/ft

aporte_aero<-c2*def_vapor

evap<-aporte_energia+aporte_aero



# Resultados explicativos

tabla<-data.frame(

Parametro=c(
"Radiacion extraterrestre",
"Radiacion neta disponible",
"Deficit de vapor",
"Aporte energetico",
"Aporte aerodinamico",
"Evaporacion final"
),

Valor=round(c(
rad_ext,
Rn_mmxd,
def_vapor,
aporte_energia,
aporte_aero,
evap
),3),

Unidad=c(
"MJ/m²/dia",
"mm/dia",
"KPa",
"mm/dia",
"mm/dia",
"mm/dia"
),

Descripcion=c(
"Energia solar disponible segun posicion solar y fecha.",
"Energia utilizada para el proceso de evaporacion.",
"Capacidad atmosferica para absorber humedad.",
"Efecto de la energia disponible sobre la evaporacion.",
"Efecto del viento y condiciones atmosfericas.",
"Evaporacion diaria calculada por Ven Te Chow."
)

)



# Graficos

tema<-theme_minimal()+
theme(plot.title=element_text(face="bold",size=15))


g_rad<-ggplot(
data.frame(
Variable=c("Radiacion extraterrestre","Rn equivalente"),
Valor=c(rad_ext,Rn_mmxd)),
aes(Variable,Valor,fill=Variable))+
geom_col()+
tema+
labs(title="Balance de radiacion",x="",y="Valor")


g_temp<-ggplot(
data.frame(
Variable=c("Tmin","Tmedia","Tmax"),
Valor=c(Tmin,temp,Tmax)),
aes(Variable,Valor,group=1))+
geom_line(linewidth=1.2,color="#1565C0")+
geom_point(size=4,color="#1565C0")+
tema+
labs(title="Variables termicas",x="",y="°C")


g_evap<-ggplot(
data.frame(
Variable=c("Energia","Aerodinamico","Total"),
Valor=c(aporte_energia,aporte_aero,evap)),
aes(Variable,Valor,fill=Variable))+
geom_col()+
tema+
labs(title="Componentes evaporacion",x="",y="mm/dia")



list(
tabla=tabla,
evap=evap,
rad=rad_ext,
def=def_vapor,
graf_rad=g_rad,
graf_temp=g_temp,
graf_evap=g_evap
)

}