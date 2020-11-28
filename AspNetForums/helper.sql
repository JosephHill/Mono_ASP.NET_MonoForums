-- Function: public.dateadd(varchar, int4, timestamptz)

-- DROP FUNCTION public.dateadd(varchar, int4, timestamptz);

CREATE OR REPLACE FUNCTION public.dateadd(varchar, int4, timestamptz)
  RETURNS timestamptz AS
'
declare
	_datepart alias for $1;
	_number alias for $2;
	_date alias for $3;
	_interval varchar(100);
begin
    
    if _datepart ilike \'y%\' then
        _interval   := cast(_number as varchar)   || \' years\';
    end if;
    if _datepart ilike \'w%\' then
        _interval   := cast(_number as varchar)  || \' weeks\';
    end if;
    if _datepart ilike \'d%\' then
        _interval   := cast(_number as varchar)  || \' days\';
    end if;
    if _datepart ilike \'h%\' then
        _interval   := cast(_number as varchar)   || \' hours\';
    end if;
    if _datepart ilike \'n%\' then
        _interval   := cast(_number as varchar)   || \' minutes\';
    end if;
    if _datepart ilike \'mi%\' then
        _interval   := cast(_number as varchar)   || \' minutes\';
    else    
        if _datepart ilike \'m%\' then
            _interval   := cast(_number as varchar)   || \' months\';
        end if;
    end if;
    if _datepart ilike \'s%\' then
        _interval   := cast(_number as varchar)   || \' seconds\';
    end if;
    return _date + _interval::text::INTERVAL;
    
end;'
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;