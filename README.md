# Análisis de cohortes y retención de usuarios

## 1. Descripción del proyecto

Este proyecto consiste en un análisis de cohortes para estudiar el comportamiento y la retención de usuarios después de su registro.

Los usuarios se agrupan según el mes de registro y se analiza su actividad durante los meses posteriores.

Además, se comparan dos tipos de adquisición:

- usuarios captados mediante promociones;
- usuarios captados de forma orgánica.

El análisis se realiza utilizando SQL y Google Sheets.


## 2. Objetivo

El objetivo principal es analizar:

- cuántos usuarios se registran en cada cohorte;
- cómo cambia la actividad de los usuarios después del registro;
- cuántos usuarios continúan activos en los meses siguientes;
- cómo se comportan las cohortes según el tipo de adquisición;
- cuál es el nivel de retención de los usuarios a lo largo del tiempo.


## 3. Herramientas utilizadas

- SQL
- PostgreSQL
- Google Sheets
- CTE (Common Table Expressions)
- Cohort Analysis
- Retention Rate
- Pivot Tables
- Slicer


## 4. Proceso de análisis

El análisis SQL se construye mediante varias CTE, donde cada etapa prepara los datos necesarios para la siguiente.

### Paso 1. Limpieza de las fechas de registro

En las CTE `clean_date_users_1` y `clean_date_users_2` se procesan los datos de registro de los usuarios.

Primero se elimina la parte de la hora y los espacios innecesarios.

Después se normalizan los separadores de las fechas (`.`, `/` y `-`) y se corrigen los formatos de año de dos y cuatro dígitos.

El objetivo es obtener un formato de fecha uniforme para poder trabajar correctamente con los datos.

### Paso 2. Preparación de los datos de usuarios

En `dateset_users` se seleccionan los campos necesarios para el análisis y se convierte la fecha normalizada en un tipo `date`.

El campo `signup_date_users` representa la fecha de registro de cada usuario.

También se conserva `promo_signup_flag`, que posteriormente permite diferenciar entre usuarios promocionales y orgánicos.

### Paso 3. Limpieza de las fechas de eventos

Las CTE `clean_date_events_1` y `clean_date_events_2` realizan un proceso similar para la tabla de eventos.

Se limpian y normalizan los valores de `event_datetime` para obtener una fecha válida y uniforme.

### Paso 4. Preparación de los datos de eventos

En `dateset_events` se seleccionan los campos necesarios de los eventos y se convierte la fecha normalizada en un tipo `date`.

El campo `date_events` representa la fecha en la que tuvo lugar el evento.

### Paso 5. Creación de la tabla de cohortes

En `cohort_table` se combinan los datos de usuarios y eventos mediante `user_id`.

En esta etapa se calculan:

- `cohort_date` — mes de registro del usuario;
- `event_month` — mes de actividad;
- `month_offset` — número de meses transcurridos desde el registro hasta la actividad.

El `month_offset` permite analizar la actividad de cada cohorte a lo largo del tiempo.

Por ejemplo:

- `month_offset = 0` — mes de registro;
- `month_offset = 1` — primer mes después del registro;
- `month_offset = 2` — segundo mes después del registro;
- etc.

También se excluyen registros sin fecha de registro, sin fecha de evento, sin tipo de evento y los eventos de prueba (`test_event`).

### Paso 6. Filtrado del período de análisis

Para el análisis final se consideran los eventos realizados entre enero y junio de 2025.

Esto permite trabajar con un período de observación de seis meses.

### Paso 7. Agregación final

En la consulta final se agrupan los datos por:

- tipo de adquisición (`promo_signup_flag`);
- mes de la cohorte (`cohort_month`);
- `month_offset`.

Para cada combinación se calcula el número de usuarios únicos mediante:

`COUNT(DISTINCT user_id)`

El resultado final se utiliza para construir la tabla de cohortes y calcular posteriormente el Retention Rate.


## 5. Retention Rate

A partir de los resultados SQL se construye en Google Sheets una tabla de Retention Rate.

El porcentaje de retención se calcula tomando como referencia el número de usuarios de cada cohorte en `month_offset = 0`.

De esta forma, el primer mes de cada cohorte representa el 100 % y los meses posteriores muestran qué porcentaje de usuarios continúa activo.


## 6. Comparación entre usuarios promocionales y orgánicos

Para comparar los diferentes tipos de adquisición se utiliza un slicer en Google Sheets basado en `promo_signup_flag`.

Esto permite visualizar:

- todos los usuarios;
- usuarios promocionales;
- usuarios orgánicos.

La comparación permite analizar tanto el tamaño de las cohortes como la evolución de la retención en cada grupo.


## 7. Resultados principales

Durante el período analizado, la adquisición orgánica generó un mayor número de usuarios que las campañas promocionales.

En los datos analizados se registraron 358 usuarios orgánicos frente a 242 usuarios procedentes de promociones.

El análisis de cohortes muestra una disminución del número de usuarios activos a medida que aumenta el número de meses desde el registro.

El Retention Rate permite observar esta evolución de forma porcentual y comparar el comportamiento de las cohortes entre los diferentes tipos de adquisición.

## 8. Resultado final

El resultado del análisis se presenta en Google Sheets mediante:

- tabla de cohortes;
- tabla de Retention Rate;
- formato condicional para visualizar los niveles de retención;
- slicer para comparar los diferentes tipos de adquisición;
- hoja independiente con las conclusiones del análisis.

📊 Google Sheets: https://docs.google.com/spreadsheets/d/1dC8e03iXKUlEQq2kjzE7pFqZVlInm07DqCLnIjifUgk/edit?usp=sharing

El archivo SQL utilizado para generar los datos se encuentra en este repositorio.




