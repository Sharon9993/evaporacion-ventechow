###############################################################
# CALCULO DE EVAPORACION - VEN TE CHOW
# Metodo combinado
# Adaptacion MATLAB --> R
# Hidroinformatica UNALM
###############################################################


rm(list=ls())
graphics.off()

library(readxl)
library(ggplot2)
library(dplyr)

#--------------------------------------------------------------
# Carpeta de resultados
#--------------------------------------------------------------

if(!dir.exists("Outputs")){
  dir.create("Outputs")
}

#--------------------------------------------------------------
# Funcion presion vapor saturado
#--------------------------------------------------------------
Pr_vap_sat <- function(T){
  6.11*exp((17.27*T)/(237.3+T))
}

#--------------------------------------------------------------
# Lectura de datos
#--------------------------------------------------------------
cat("\n==============================\n")
cat(" LECTURA DATA_EVAP\n")
cat("==============================\n")

archivo <- file.choose()

datos <- read_excel(
  archivo,
  col_names=FALSE
)

lat <- as.numeric(datos[1,1])
alt <- as.numeric(datos[1,2])

ano <- as.numeric(datos[1,3])
mes <- as.numeric(datos[1,4])
dia <- as.numeric(datos[1,5])

Rn <- as.numeric(datos[1,6])
Roc <- as.numeric(datos[1,7])
Rext <- as.numeric(datos[1,8])


temp <- as.numeric(datos[1,9])
Tpr <- as.numeric(datos[1,10])

Tmin <- as.numeric(datos[1,11])
Tmax <- as.numeric(datos[1,12])

n_sol <- as.numeric(datos[1,13])
albedo <- as.numeric(datos[1,14])

hr <- as.numeric(datos[1,15])
vv <- as.numeric(datos[1,16])

cat("Latitud:",lat,"\n")
cat("Altitud:",alt,"\n")
cat("Temperatura media:",temp,"°C\n")

#--------------------------------------------------------------
# Calculo astronomico
#--------------------------------------------------------------
cat("\nCALCULO ASTRONOMICO\n")

fecha <- as.Date(
  paste(ano,mes,dia,sep="-")
)

nj <- as.numeric(
  format(fecha,"%j")
)

dec_sol <- 
0.4093*
sin((2*pi*nj/365)-1.405)

lat_rad <- lat*pi/180

ang_atard <-
acos(
-tan(lat_rad)*tan(dec_sol)
)

max_N <-
24*ang_atard/pi

dist_sol <-
1+
0.033*cos(2*pi*nj/365)

rad_ext <-
15.392*
dist_sol*
(
ang_atard*sin(lat_rad)*sin(dec_sol)+
cos(lat_rad)*cos(dec_sol)*sin(ang_atard)
)

cat("Dia juliano:",nj,"\n")

cat(
"Radiacion extraterrestre:",
round(rad_ext,3),
"MJ/m2/dia\n"
)

#--------------------------------------------------------------
# Energia disponible
#--------------------------------------------------------------
cat("\nENERGIA DISPONIBLE\n")

factor_temp <-
2.501-0.002361*temp

Rn_mmxd <-
Rn/factor_temp

cat(
"Radiacion neta:",
round(Rn_mmxd,3),
"mm/dia\n"
)

#--------------------------------------------------------------
# Deficit de vapor
#--------------------------------------------------------------
cat("\nDEFICIT DE VAPOR\n")

def_vapor <-
(
((Pr_vap_sat(Tmax)+Pr_vap_sat(Tmin))*0.5*
(1-hr/100))/10
)

cat(
"Deficit vapor:",
round(def_vapor,3),
"KPa\n"
)

#--------------------------------------------------------------
# Evaporacion final
#--------------------------------------------------------------
patm <-
101.3*
((293-0.0065*alt)/293)^5.256

c_psi <-
(0.0016286*patm)/
factor_temp

delta <-
(4098*(Pr_vap_sat(temp)/10))/
(237.3+temp)^2

c1 <-
delta/(delta+c_psi)

c2 <-
(c_psi/(delta+c_psi))*
(6.43*(1+0.536*vv))/
factor_temp

aporte_energia <-
c1*Rn_mmxd/factor_temp

aporte_aero <-
c2*def_vapor

evap <-
aporte_energia+aporte_aero

cat("\n==============================\n")
cat(" RESULTADO FINAL\n")
cat("==============================\n")

cat(
"Evaporacion:",
round(evap,3),
"mm/dia\n"
)

#==============================================================
# GRAFICOS
#==============================================================
tema_hidro <-
theme_minimal()+
theme(
plot.title=element_text(
size=16,
face="bold"
),
axis.title=element_text(
face="bold"
),
panel.grid.major=
element_line(color="gray85")
)

#--------------------------------------------------------------
# Grafico radiacion
#--------------------------------------------------------------
graf_rad <- data.frame(
variable=c(
"Radiacion extraterrestre",
"Rn equivalente"
),
valor=c(
rad_ext,
Rn_mmxd
)
)

p1 <- ggplot(
graf_rad,
aes(
variable,
valor,
fill=variable
)
)+
geom_col(width=.65)+
geom_text(
aes(label=round(valor,2)),
vjust=-.4
)+
scale_fill_manual(
values=c(
"#1565C0",
"#26A69A"
)
)+
tema_hidro+
labs(
title="Balance de Radiacion",
x="",
y="Valor"
)+
theme(
legend.position="none"
)

print(p1)

ggsave(
"Outputs/Grafico_Radiacion.png",
p1,
width=8,
height=5,
dpi=300
)

#--------------------------------------------------------------
# Grafico temperaturas
#--------------------------------------------------------------
graf_temp <- data.frame(
tipo=c(
"Tmin",
"Tmedia",
"Tmax",
"Trocío"
),
valor=c(
Tmin,
temp,
Tmax,
Tpr
)
)

p2 <- ggplot(
graf_temp,
aes(
tipo,
valor,
group=1,
color=tipo
)
)+
geom_line(size=1.4)+
geom_point(size=4)+
scale_color_manual(
values=c(
"#2196F3",
"#4CAF50",
"#F44336",
"#9C27B0"
)
)+
tema_hidro+
labs(
title="Variables Termicas",
x="",
y="Temperatura °C"
)+
theme(
legend.position="none"
)

print(p2)

ggsave(
"Outputs/Grafico_Temperaturas.png",
p2,
width=8,
height=5,
dpi=300
)

#--------------------------------------------------------------
# Componentes evaporacion
#-------------------------------------------------------------
graf_evap <- data.frame(
componente=c(
"Energia",
"Aerodinamico",
"Total"
),
valor=c(
aporte_energia,
aporte_aero,
evap
)
)

p3 <- ggplot(
graf_evap,
aes(
componente,
valor,
fill=componente
)
)+
geom_col(width=.65)+
geom_text(
aes(label=round(valor,3)),
vjust=-.4
)+
scale_fill_manual(
values=c(
"#0277BD",
"#FB8C00",
"#2E7D32"
)
)+
tema_hidro+
labs(
title="Componentes de Evaporacion",
x="",
y="mm/dia"
)+
theme(
legend.position="none"
)

print(p3)

ggsave(
"Outputs/Grafico_Componentes_Evaporacion.png",
p3,
width=8,
height=5,
dpi=300
)

#--------------------------------------------------------------
# Aportes porcentuales
#--------------------------------------------------------------
graf_pie <- data.frame(
tipo=c(
"Energia",
"Aerodinamico"
),
valor=c(
aporte_energia,
aporte_aero
)
)

p4 <- ggplot(
graf_pie,
aes(
"",
valor,
fill=tipo
)
)+
geom_col(width=1)+
coord_polar(theta="y")+
scale_fill_manual(
values=c(
"#1565C0",
"#FB8C00"
)
)+
theme_void()+
labs(
title="Contribucion de mecanismos de evaporacion"
)

print(p4)

ggsave(
"Outputs/Grafico_Aportes_Evaporacion.png",
p4,
width=7,
height=7,
dpi=300
)

#--------------------------------------------------------------
# Reporte TXT
#--------------------------------------------------------------
sink(
"Outputs/Reporte_Evaporacion.txt"
)

cat("===============================\n")
cat(" REPORTE EVAPORACION\n")
cat(" VEN TE CHOW\n")
cat("===============================\n\n")

cat(
"Fecha:",
dia,"/",
mes,"/",
ano,"\n"
)

cat(
"Latitud:",
lat,"\n"
)

cat(
"Altitud:",
alt,
"m\n\n"
)

cat(
"Temperatura media:",
temp,
"°C\n"
)

cat(
"Radiacion extraterrestre:",
round(rad_ext,3),
"MJ/m2/dia\n"
)

cat(
"Radiacion neta:",
round(Rn_mmxd,3),
"mm/dia\n"
)

cat(
"Deficit vapor:",
round(def_vapor,3),
"KPa\n"
)

cat(
"Aporte energetico:",
round(aporte_energia,3),
"mm/dia\n"
)

cat(
"Aporte aerodinamico:",
round(aporte_aero,3),
"mm/dia\n"
)

cat(
"\nEVAPORACION FINAL:",
round(evap,3),
"mm/dia\n"
)

sink()

cat("\n=================================\n")
cat(" ARCHIVOS GENERADOS EN OUTPUTS\n")
cat("=================================\n")
cat("Proceso terminado correctamente\n")