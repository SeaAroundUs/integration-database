create or replace function distribution.effective_distance(i_tl Float, i_hditemp Float) 
returns float as
$body$
declare
  --=================================================================================
  --A function to calculate the effective distance of abundance
  --=================================================================================
  --Inputs: TL=total length; HDITemp=Habitat diversity index (number of occurrence habitat/total no. of habitat)
  
  TL Float[];     -- Membership to 3 length classes (small, medium, large)
  HDI Float[];    -- Membership to 3 habitat diversity classes (low, moderate, high)
  EDist Float[];  -- Membership to 3 effective distance classes)
begin             
  --fuzzifying length
  TL[0] := distribution.fuzzify(i_tl, 1, 0.0, 0.0, 25.0, 50.0, 0.0);
  TL[1] := distribution.fuzzify(i_tl, 1, 25.0, 50.0, 100.0, 150.0, 0.0);
  TL[2] := distribution.fuzzify(i_tl, 1, 100.0, 150.0, 1000.0, 2000.0, 0.0);
                                 
  --fuzzifying habitat diversity
  HDI[0] := distribution.fuzzify(i_hditemp, 1, 0.0, 0.0, 0.25, 0.5, 0.0);
  HDI[1] := distribution.fuzzify(i_hditemp, 2, 0.25, 0.5, 0.75, 0.0, 0.0);
  HDI[2] := distribution.fuzzify(i_hditemp, 1, 0.5, 0.75, 1.0, 1.1, 0.0);
  
  --Calling rules to determine effective distance
  EDist[0] := (select avg(d) from (values(least(TL[0], HDI[0])), (least(TL[1], HDI[0])), (least(TL[2], HDI[0]))) as t(d));
  EDist[1] := (select avg(d) from (values(least(TL[0], HDI[1])), (least(TL[1], HDI[1])), (least(TL[0], HDI[2]))) as t(d));
  EDist[2] := (select avg(d) from (values(least(TL[2], HDI[1])), (least(TL[1], HDI[2])), (least(TL[2], HDI[2]))) as t(d));
  
  --defuzzification to estimate absolute effective distance
  return (EDist[0] * 0.01 + EDist[1] * 0.5 + EDist[2] * 1.0) / (EDist[0] + EDist[1] + EDist[2] + 0.000000001)*100.0;
end;
$body$                                    
language plpgsql;                              

-- Triangle distribution
create or replace function distribution.triangle(x float, a float, b float, c float) 
returns float as
$body$
declare
  temp float;        
begin
  if x <= a then 
    temp := 0;                                                       
  elsif x > a and x < b then 
    temp := (x - a) / (b - a);
  elsif x >= b and x < c then 
    temp := (c - x) / (c - b);
  end if;
  
  if x >= c then 
    temp := 0;
  end if;
  
  return temp;
end;
$body$                    
language plpgsql;

                 
-- Trapezoidal distribution
create or replace function distribution.trapezoid(x float, a float, b float, c float, d float) 
returns float as
$body$
declare
  temp float;
begin
  if x <= a then 
    temp := 0.0;
  elsif x > a and x < b then 
    temp := (x - a) / (b - a);
  elsif x >= b and x < c then 
    temp := 1.0;
  elsif x >= c and x < d then 
    temp := (d - x) / (d - c);
  end if;
  
  if x >= d then 
    temp := 0.0;
  end if;                                                  
  
  return temp;
end;
$body$                    
language plpgsql;

           
create or replace function distribution.fuzzify(
  i_domain_values float, 
  i_fmf_shape integer, 
  i_parameter_a float, 
  i_parameter_b float,
  i_parameter_c float, 
  i_parameter_d float = null, 
  i_alphacut float = null
)                       
returns float as
$body$
declare
  --=========================================================================
  --This function returns a fuzzy membership based on the input domains, the specified FMF shape
  --and parameters for the FMF
  --=========================================================================
  rtn_val float;
begin
  if i_domain_values is distinct from 0 then
      case i_fmf_shape
          when 1 then -- Trapezoid distribution
              rtn_val := distribution.trapezoid(i_domain_values, i_parameter_a, i_parameter_b, i_parameter_c, i_parameter_d);
          when 2 then -- Triangle distribution
              rtn_val := distribution.triangle(i_domain_values, i_parameter_a, i_parameter_b, i_parameter_c);
          /* These were commmented out in the original macro
          when 3 then -- Logistic decline distribution
              rtn_val := distribution.logistic_D(i_domain_values, i_parameter_a, i_parameter_b, i_parameter_c)
          when 4 then -- Logistic growth distribution
              rtn_val := distribution.logistic_G(i_domain_values, i_parameter_a, i_parameter_b, i_parameter_c)
          */
      end case;
      
      if rtn_val <= i_alphacut then 
        rtn_val := 0.0;
      end if;
  end if;
                                       
  return rtn_val;
end;
$body$                    
language plpgsql;

