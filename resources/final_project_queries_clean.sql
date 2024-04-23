-- Revenue per division
select n_a.description_section, n_a.code_division, n_a.description_division, round(sum(i_n.ca_1/1000000)) as revenue_in_million
from infogreffe_numbers as i_n
left join general as g using(siren)
left join naf2 as n on n.sous_classe = g.naf2_code
join naf2_agreg as n_a on n.division = n_a.code_division
group by n_a.description_division, n_a.code_division, n_a.description_section
order by revenue_in_million desc;

-- Calculating the french_revenue
select SUM(i_n.ca_1) as total
    from infogreffe_numbers as i_n
    join infogreffe_general as i_g using(siren)
    where i_g.region is not null ;
-- Revenue per region
select i_g.region, round(sum(i_n.ca_1/1000000)) as revenue_in_million, 
round(sum(i_n.ca_1/1048967325250)*100) as french_percentage
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
where i_g.region is not null
group by i_g.region
order by revenue_in_million desc;

-- Top 10 ape codes in revenue in Ile de France and in quantities
select i_g.code_ape, i_g.libelle_ape, round(sum(i_n.ca_1/1000000),2) as revenue_in_million,
round((sum(i_n.resultat_1)/sum(i_n.ca_1))*100) as income_in_percent, count(distinct siren) as number_companies
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
where i_g.region = 'Ile-de-France' and i_g.code_ape is not null
group by i_g.code_ape, i_g.libelle_ape
order by revenue_in_million desc;

-- Zoom on 6202A and 7022Z
-- How many in France
select i_g.code_ape, i_g.libelle_ape, count(distinct i_n.siren), 
round(sum(i_n.ca_1/1000000),2) as revenue_in_million
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
where i_g.code_ape in ('6202A','7022Z')
group by i_g.code_ape, i_g.libelle_ape
order by revenue_in_million desc;
-- How many in Paris
select i_g.code_ape, i_g.libelle_ape, i_g.departement, count(distinct i_n.siren), 
round(sum(i_n.ca_1/1000000),2) as revenue_in_million
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
where i_g.code_ape in ('6202A','7022Z') and i_g.num_dept = 75
group by i_g.code_ape, i_g.libelle_ape, i_g.departement
order by revenue_in_million desc;

-- Biggest employers and revenue for 62.02A, in Paris
select i_g.code_ape, n_l.denomination, i_g.departement, n_l.avg_workforce, 
round(n_l.revenue_10m,2), round(i_n.resultat_1/1000000,2) as income_in_million
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
join numbers_light as n_l using(siren)
where i_g.code_ape in ('6202A') and i_g.num_dept = 75
order by n_l.avg_workforce desc;
-- Biggest employers and revenue for 70.22Z, in Paris
select i_g.code_ape, n_l.denomination, i_g.departement, n_l.avg_workforce, 
round(n_l.revenue_10m,2), round(i_n.resultat_1/1000000,2) as income_in_million
from infogreffe_numbers as i_n
join infogreffe_general as i_g using(siren)
join numbers_light as n_l using(siren)
where i_g.code_ape in ('7022Z') and i_g.num_dept = 75
order by n_l.avg_workforce desc;

select distinct(bnf.web_sites)
from general as g
left join naf2 as n on n.sous_classe = g.naf2_code
left join naf2_agreg as n_a on n.division = n_a.code_division
left join agreg_to_bnf as a_g using(description_division)
left join bnf_exploded as bnf using(bnf_names)
where g.naf2_code in ('2110Z');