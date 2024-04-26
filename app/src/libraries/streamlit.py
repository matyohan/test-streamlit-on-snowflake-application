# Import libraries
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import sum, col, when, max, lag
from snowflake.snowpark import Window
from datetime import timedelta
import altair as alt
import streamlit as st
import pandas as pd
import snowflake.permissions as permissions

##import plotly.express as px 
import datetime as dt

# Set page config
st.set_page_config(layout="wide")
# Get current session
session = get_active_session()

#TITRE
st.header("TEST SNOWFLAKE APP")
st.subheader(":dart: 1 VALIDER L'ACCES A UNE TABLE CRÉÉE DANS L'APP SNOWFLAKE")

#######################################################################################
#VALIDER L'ACCES A LA TABLE DE PARAMETRAGE QUI EST CRÉÉE DANS LE SCHEMA DE L'APPLICATION
#######################################################################################


#On affiche la table de paramétrage 
table_list="TABLE_LIST"
table_list_df=session.table(table_list).to_pandas()

#On permet à l'utilisateur de modifier la table de paramétrage
with st.form("table write"):
    df_edited=st.experimental_data_editor(table_list_df, use_container_width= True , num_rows="dynamic")
    write_to_snowflake=st.form_submit_button("UPDATE")

#Mise à jour dans Snowflake 
if write_to_snowflake:
    with st.spinner("UPDATING..."):
        try:
            session.write_pandas(df_edited, table_list, overwrite = True)
            session.sql('GRANT SELECT ON TABLE TABLE_LIST TO APPLICATION ROLE app_instance_role').collect()
        except:
            st.write('Error saving to table.')
    st.success("The input table has been successfully updated in Snowflake!")

st.divider()


#######################################################################################
#VALIDER L'ACCES A UNE TABLE DE NOTRE ENVIRONNEMENT SNOWFLAKE VIA UNE APP
#######################################################################################


st.subheader(":dart: 2 VALIDER L'ACCES A UNE TABLE DE NOTRE ENVIRONNEMENT SNOWFLAKE VIA UNE APP")




#######################################################################################
#VALIDER LA POSSIBILITE D'ECRITURE DANS LE SCHEMA DE L'APP
#######################################################################################


st.subheader(":dart: 2 VALIDER L'ACCES A UNE TABLE DE NOTRE ENVIRONNEMENT SNOWFLAKE VIA UNE APP")


