/* 
    Creates the view for a col and sections, Not scaleable as a view, but runs quickly 
    for each column.

    Returns the top interval and bottom interval of each section in the column.
    Top interval is defined as unit.lo where unit.position_bottom is smallest.
    Likewise bottom interval is unit.fo where unit.position_bottom is greatest! 
 */
DROP FUNCTION macrostrat_api.get_col_section_data(int);
CREATE OR REPLACE FUNCTION macrostrat_api.get_col_section_data(column_id INT) 
RETURNS TABLE (
    id INT, 
    unit_count BIGINT, 
    top varchar(200), 
    bottom varchar(200)) 
AS
$$
BEGIN 
RETURN QUERY
    SELECT 
        s.id,
        COUNT(uc) as unit_count,
        lo.interval_name as top,
        fo.interval_name as bottom
    FROM macrostrat.sections s 
    JOIN macrostrat.units uc 
      ON uc.section_id = s.id
    JOIN macrostrat.units u 
      ON u.section_id = s.id
    JOIN macrostrat.units un
      ON un.section_id = s.id
    JOIN macrostrat.intervals fo
      ON un.fo = fo.id
    JOIN macrostrat.intervals lo
      ON u.lo = lo.id
    WHERE u.position_bottom = (
        SELECT MIN(position_bottom) FROM macrostrat.units WHERE section_id = u.section_id
    ) AND un.position_bottom = (
        SELECT MAX(position_bottom) FROM macrostrat.units WHERE section_id = un.section_id
    ) AND s.col_id = column_id
    GROUP BY s.id, lo.interval_name, fo.interval_name, fo.age_bottom ORDER BY fo.age_bottom
    ;
END
$$ LANGUAGE plpgsql;
