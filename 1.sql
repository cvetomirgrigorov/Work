# Work
DZI

Клиент, полица, вид застраховка:

Какво да се извлече като информация (select clause):
1. име на клиент  (p_people.name)
2. 'ФЛ' / 'ЮЛ' в зависимост дали клиентът е физичско или юридическо лице (ако p_people.man_comp = 1 => ФЛ, 2 => ЮЛ; употреба на decode или case конструкция)
3. номер("име") на полица (policy.policy_no)
4. начална дата на полица (policy.insr_begin)
5. крайна дата на полица  (policy.insr_end)
6. код на застраховка (ht_insr_type.id)
7. име на вида застраховка (ht_insr_type.name)
*Резултатът да е подреден по код застраховка и име на клиент

Условия (where clause):
1. Само автомобилни застраховки: с кодове (policy.insr_type) за КАСКО - 4401, 4402, за ГО - 4307, 4308
2. С начална дата през януари 2013г.
3. Само активни полици ( policy.policy_state in (0,11,12) )

Таблици:
policy, ht_insr_type, p_clients, p_people






-- primer
select * from (
      select pp.name, 
             decode(pp.man_comp,1,'ФЛ','ЮЛ') fl_ul,
             decode(pp.man_comp,1,decode(pp.sex,1,'ФЛ-мъж','ФЛ-жена'),'ЮЛ') fl_ul_3,
             case when pp.man_comp=1 and pp.sex=1 then 'ФЛ-мъж'
                  when pp.man_comp=1 and pp.sex=2 then 'ФЛ-жена'
                  else 'ЮЛ' end  fl_ul_2,
             p.policy_no,
             p.insr_begin,
             p.insr_end,
             h.id insr_code,
             h.name insr_name,
             (select pa.agent_no from p_agents pa where pa.agent_id = p.agent_id) agent_no
        from policy p, p_clients pc, p_people pp, ht_insr_type h
       where pp.man_id = pc.man_id
         and pc.client_id = p.client_id
         and h.id = p.insr_type
         and p.insr_type like '11%'
         --and p.insr_end between to_date('01012013','ddmmyyyy') and to_date('31012013','ddmmyyyy')
         and p.insr_end between '01_01_2013' and '31012013'
         and p.policy_state in (0,11,12)
         and not exists (select gi.install_id from gen_instalments gi where gi.policy_id = p.policy_id)
         --and rownum<10
      order by h.id, pp.name   
)  t 
where rownum < 10 
   ;
   
   
select * from policy where policy_no='110112024000003';   
select distinct man_comp,sex as pol from p_people order by 1 desc, pol;

select man_id, count(*), count(distinct office_id) from p_agents group by man_id having count(*)>1;

select * from p_agents where man_id=1250000017;

select client_id, count(*), count(distinct insr_type) from policy 
group by client_id having count(*)>1 and count(distinct insr_type)>1;
