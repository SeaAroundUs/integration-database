update master.taxon
   set lineage = 
         (COALESCE(phylum, 'Others') || 
          case when taxon_level_id > 1 
          then coalesce('.' || cla_code::varchar, '') || 
               case when taxon_level_id > 2
               then coalesce('.' || ord_code::varchar, '') ||
                    case when taxon_level_id > 3
                    then coalesce('.' || fam_code::varchar, '') ||
                         case when taxon_level_id > 4
                         then coalesce('.' || gen_code::varchar, '') ||
                              case when taxon_level_id > 5
                              then coalesce('.' || spe_code::varchar, '')
                              else ''
                              end
                         else ''
                         end
                    else ''
                    end
               else ''
               end
          else ''
          end)::ltree
;

update log.taxon
   set lineage = 
         (phylum || 
          case when taxon_level_id > 1 
          then coalesce('.' || cla_code::varchar, '') || 
               case when taxon_level_id > 2
               then coalesce('.' || ord_code::varchar, '') ||
                    case when taxon_level_id > 3
                    then coalesce('.' || fam_code::varchar, '') ||
                         case when taxon_level_id > 4
                         then coalesce('.' || gen_code::varchar, '') ||
                              case when taxon_level_id > 5
                              then coalesce('.' || spe_code::varchar, '')
                              else ''
                              end
                         else ''
                         end
                    else ''
                    end
               else ''
               end
          else ''
          end)::ltree
;
