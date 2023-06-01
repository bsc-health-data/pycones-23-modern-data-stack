
    
    

select
    person_id as unique_field,
    count(*) as n_records

from "iomed"."cdm"."person"
where person_id is not null
group by person_id
having count(*) > 1


