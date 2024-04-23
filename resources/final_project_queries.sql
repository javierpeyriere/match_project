select * from management limit 50;


select inf_gen.denomination, inf_gen.siren, inf_gen.departement, inf_num.ca_1, inf_num.ca_2, inf_num.ca_3
from infogreffe_numbers as inf_num
inner join infogreffe_general as inf_gen
on inf_gen.siren = inf_num.siren
where inf_num.ca_1 < inf_num.ca_2 and inf_num.ca_2 < inf_num.ca_3 and inf_gen.departement = 'Paris' and inf_num.ca_1 > 1000000;

select inf_gen.siren, inf_gen.denomination, inf_gen.departement, 
	inf_num.ca_1/1000000 as rev_1_million, inf_num.ca_2/1000000 as rev_2_million, inf_num.resultat_1/1000000 as earnings_1_million, num_li.avg_workforce,
    inf_num.resultat_1/num_li.avg_workforce as earnings_per_employee, inf_num.ca_1/num_li.avg_workforce as rev_per_employee
from numbers_light as num_li
inner join infogreffe_numbers as inf_num on num_li.siren = inf_num.siren
inner join infogreffe_general as inf_gen on inf_num.siren = inf_gen.siren
where num_li.siren is not null and num_li.avg_workforce > 0 and inf_num.resultat_1 < inf_num.ca_2
order by earnings_per_employee desc;

select inf_gen.siren, inf_gen.denomination, inf_gen.departement, 
	num_li.naf2_code, naf2.intitule_naf_rev_2,
	inf_num.ca_1/1000000 as rev_1_million,  inf_num.resultat_1/1000000 as earnings_1_million, num_li.avg_workforce,
    inf_num.resultat_1/num_li.avg_workforce as earnings_per_employee, inf_num.ca_1/num_li.avg_workforce as rev_per_employee
from numbers_light as num_li
inner join infogreffe_numbers as inf_num on num_li.siren = inf_num.siren
inner join infogreffe_general as inf_gen on inf_num.siren = inf_gen.siren
inner join naf2 as naf2 on num_li.naf2_code = naf2.sous_classe
where naf2.sous_classe in ('6202A', '7021Z', '7022Z') and num_li.avg_workforce > 0
order by earnings_per_employee desc;

select n_l.denomination, n_l.naf2_code, g.naf2_activity as actity, n_l.avg_workforce, n_l.revenue_10m 
from numbers_light as n_l
join general as g using(siren)
where n_l.naf2_code in ('6202A', '70.22Z') and g.city = 'Paris';

select naf2.division, info_gene.code_ape, info_gene.libelle_ape, bnf.web_sites -- to change the query
from bnf_exploded as bnf
join agreg_to_bnf using (bnf_names)
join naf2_agreg as naf2_a using (description_division)
join naf2 as naf2 on naf2_a.code_division = naf2.division
join general as gene on naf2.sous_classe = gene.naf2_code
right join infogreffe_numbers as info_num using (siren)
join infogreffe_general as info_gene using (siren)
where info_gene.code_ape in ('6202A', '7021Z', '7022Z') and info_gene.ville = 'Paris'
limit 50;

-- Search for html recommended from a name of a company
select gene.siren, gene.denomination, naf2.division, gene.naf2_code, gene.naf2_activity, bnf.web_sites
from bnf_exploded as bnf
join agreg_to_bnf using (bnf_names)
join naf2_agreg as naf2_a using (description_division)
join naf2 as naf2 on naf2_a.code_division = naf2.division
join general as gene on naf2.sous_classe = gene.naf2_code
where gene.denomination like ('%gaumont rennes%')
limit 50;

select denomination, code_ape, libelle_ape from infogreffe_general
where code_ape in ('6202A', '7021Z', '7022Z');

select info_gene.code_ape, info_gene.libelle_ape, count(info_gene.siren) as num_per_ape, avg(info_num.ca_1)/1000000 as mean_ca_y1_in_million
from infogreffe_numbers as info_num
join infogreffe_general as info_gene using (siren)
group by info_gene.code_ape, info_gene.libelle_ape
order by mean_ca_y1_in_million desc;

-- Query to see some info from code_ape and department
select i_g.code_ape, i_g.libelle_ape, i_n.siren, i_n.denomination, i_g.code_postal, 
	i_n.tranche_ca_millesime_1, i_n.ca_1, i_n.resultat_1, i_n.ca_2, i_n.resultat_2, i_n.ca_3, i_n.resultat_3
from infogreffe_numbers as i_n
inner join infogreffe_general as i_g using(siren)
where code_ape = '4634Z' and num_dept = 75;

select siren, denomination, tranche_ca_millesime_1, ca_1, resultat_1, ca_2, resultat_2, ca_3, resultat_3
from infogreffe_numbers 
where code_ape = '4634Z' and num_dept = 75;

-- Query to see the revenue on the 3 previous years
select info_num.siren, info_num.denomination, info_num.ca_1/1000000 as ca_2022_million, info_num.ca_2/1000000 as ca_2021_million, info_num.ca_3/1000000 as ca_2020_million, ville
from infogreffe_numbers as info_num
inner join infogreffe_general as info_gene using(siren)
limit 100;

select tranche_ca_millesime_1, sum(ca_1)/1000000 as total_rev_in_million, count(siren)
from infogreffe_numbers
group by tranche_ca_millesime_1;

select i_g.siren, i_g.denomination, i_g.code_ape, i_g.libelle_ape, i_g.adresse, i_g.code_postal, i_g.ville, 
n_l.avg_workforce, n_l.revenue_10m as rev_in_10_million, n_l.op_inc_percent, n_l.dep_percent, n_l.borrowed, n_l.cash_percent, n_l.secure_investment_percent
from infogreffe_general as i_g
left join numbers_light as n_l using(siren)
where siren = 432778108;


select * from numbers_light
where naf2_code in ('6202A', '7021Z', '7022Z') and avg_workforce >= 1 and denomination like ('%EBAY%');

select i_g.siren, i_g.denomination, i_g.code_ape, i_g.libelle_ape, i_g.adresse, i_g.code_postal, i_g.ville, 
n_l.avg_workforce, n_l.revenue_10m as rev_in_10_million, n_l.op_inc_percent, n_l.dep_percent, n_l.borrowed, n_l.cash_percent, n_l.secure_investment_percent
from infogreffe_general as i_g
left join numbers_light as n_l using(siren)
where i_g.denomination like('%total%');

select n_l.denomination, n_l.siren, n_l.avg_workforce, n_l.revenue_10m, i_n.resultat_1, i_n.resultat_2, i_n.resultat_3
from numbers_light as n_l
inner join infogreffe_numbers as i_n using(siren)
where i_n.resultat_1 is null and n_l.avg_workforce <= 0;

select n_l.denomination, n_l.siren, n_l.avg_workforce, n_l.revenue_10m, i_n.resultat_1, i_n.resultat_2, i_n.resultat_3
from numbers_light as n_l
inner join infogreffe_numbers as i_n using(siren)
where i_n.resultat_1 is null and n_l.avg_workforce > 0;

select i_n.denomination, n_l.siren, n_l.avg_workforce, n_l.revenue_10m, i_n.resultat_1, i_n.resultat_2, i_n.resultat_3
from infogreffe_numbers as i_n 
join infogreffe_general as i_g using(siren)
join numbers_light as n_l using(siren)
where i_n.siren = '495255689';

SELECT user, host FROM mysql.user;