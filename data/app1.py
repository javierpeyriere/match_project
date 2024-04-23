# Librairies needed and other functions
import json
import math
from collections import defaultdict
from flask import Flask, abort, request
from flask_basicauth import BasicAuth
from flask_swagger_ui import get_swaggerui_blueprint
import pymysql
import os
import requests  # to use if we need to get something from our api


app = Flask(__name__)
app.config.from_file("flask_config.json", load=json.load)
auth = BasicAuth(app)

# To show the nice yaml info on the /docs of my api url!!
swaggerui_blueprint = get_swaggerui_blueprint(
    base_url='/docs',
    api_url='/static/openapi.yaml',
)
app.register_blueprint(swaggerui_blueprint)

def remove_null_fields(obj):
    """Function to remove a key from the display if its value is empty"""
    return {k:v for k, v in obj.items() if v is not None}

@app.route("/code_ape")
@auth.required
def code_ape():
    """function to show the name of the companies with this code_ape, 
    per department number"""
    include_details = bool(int(request.args.get('include_details', 0)))
    ape_number = str(request.args.get('ape_number', '7022Z'))
    chosen_dept = str(request.args.get('department', 75))
 
    db_conn = pymysql.connect(host="localhost", user="root", password = "Alsimar10",database="match_project",
                              cursorclass=pymysql.cursors.DictCursor)

    sql1 = """select code_ape, libelle_ape, siren, denomination, code_postal
            from infogreffe_general """
    sql2 = """select i_g.code_ape, i_g.libelle_ape, i_n.siren, 
                i_n.denomination, i_g.code_postal, i_n.tranche_ca_millesime_1,
                i_n.ca_1, i_n.resultat_1, i_n.ca_2, i_n.resultat_2, i_n.ca_3,
                i_n.resultat_3
            from infogreffe_numbers as i_n
            inner join infogreffe_general as i_g using(siren) """
    sql3 = """ where code_ape = %s and num_dept = %s"""

    # Check if there are details requested
    if include_details:
        sql = sql1 + sql3
    else:
        sql = sql2 + sql3

    # get data
    with db_conn.cursor() as cursor:
        cursor.execute(sql, (ape_number, chosen_dept ) )
        companies = cursor.fetchall()
        if not companies:
            abort(404)
        companies = [remove_null_fields(comp) for comp in companies]
        #company_names = [comp['denomination'] for comp in companies]
    db_conn.close()

    # creating a dictionary
    result = {}
    i=0
    for company in companies:
        i+=1
        comp = "company_" + str(i)
        result[comp] = remove_null_fields(company)

    return result

@app.route("/siren/<siren_num>")
@auth.required
def siren(siren_num):
    #Connecting to mysql
    db_conn = pymysql.connect(host="localhost", user="root", password = "Alsimar10",database="match_project",
                              cursorclass=pymysql.cursors.DictCursor)
    with db_conn.cursor() as cursor:
        cursor.execute("""
            select 
                i_g.siren, i_g.denomination, i_g.code_ape, i_g.libelle_ape, 
                i_g.adresse, i_g.code_postal, i_g.ville, 
                n_l.avg_workforce, n_l.revenue_10m as rev_in_10_million,
                n_l.op_inc_percent, n_l.dep_percent, n_l.borrowed, 
                n_l.cash_percent, n_l.secure_investment_percent
            from infogreffe_general as i_g
            left join numbers_light as n_l using(siren)
            where siren = %s
        """, (siren_num, ))
        company = cursor.fetchone()
        if not company:
            abort(404)
        company = remove_null_fields(company)    

    db_conn.close()

    return company

@app.route("/company")
@auth.required
def company(): 
    piece_of_name = "%"+str(request.args.get('name'))+"%"

    # Preparing the 'select' for the company name check
    sql = """
            select 
                i_g.siren, i_g.denomination, i_g.code_ape, i_g.libelle_ape,
                i_g.adresse, i_g.code_postal, i_g.ville, 
                n_l.avg_workforce, n_l.revenue_10m as rev_in_10_million, 
                n_l.op_inc_percent, n_l.dep_percent, n_l.borrowed, 
                n_l.cash_percent, n_l.secure_investment_percent
            from infogreffe_general as i_g
            left join numbers_light as n_l using(siren)
            where i_g.denomination like %s
        """
    #Connecting to mysql
    db_conn = pymysql.connect(host="localhost", user="root", password = "Alsimar10",database="match_project",
                              cursorclass=pymysql.cursors.DictCursor)
    with db_conn.cursor() as cursor:
        cursor.execute(sql, (piece_of_name,))
        companies = cursor.fetchall()
        if not companies:
            abort(404)
        companies = [remove_null_fields(c) for c in companies]

    db_conn.close()

    # creating a dictionary
    result = {}
    i=0
    for company in companies:
        i+=1
        comp = "company_" + str(i)
        result[comp] = remove_null_fields(company)

    return result

