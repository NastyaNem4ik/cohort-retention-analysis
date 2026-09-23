with clean_date_users_1 as (
    select *,
        replace(
            replace(
                split_part(trim(signup_datetime), ' ', 1),
                '.',
                '-'
            ),
            '/',
            '-'
        ) as clean_time
    from cohort_users_raw
),

clean_date_users_2 as (
    select *,
        lpad(split_part(clean_time, '-', 1), 2, '0')
        || '-' ||
        lpad(split_part(clean_time, '-', 2), 2, '0')
        || '-' ||
        case
            when length(split_part(clean_time, '-', 3)) = 2
                then '20' || split_part(clean_time, '-', 3)
            else split_part(clean_time, '-', 3)
        end as normalized_date
    from clean_date_users_1
),

dateset_users as (
    select
        user_id,
        full_name,
        email,
        country,
        signup_source,
        signup_device,
        promo_signup_flag,
        to_date(normalized_date, 'DD-MM-YYYY') as signup_date_users
    from clean_date_users_2
),

clean_date_events_1 as (
    select *,
        replace(
            replace(
                split_part(trim(event_datetime), ' ', 1),
                '.',
                '-'
            ),
            '/',
            '-'
        ) as clean_time
    from cohort_events_raw
),

clean_date_events_2 as (
    select *,
        lpad(split_part(clean_time, '-', 1), 2, '0')
        || '-' ||
        lpad(split_part(clean_time, '-', 2), 2, '0')
        || '-' ||
        case
            when length(split_part(clean_time, '-', 3)) = 2
                then '20' || split_part(clean_time, '-', 3)
            else split_part(clean_time, '-', 3)
        end as normalized_date
    from clean_date_events_1
),

dateset_events as (
    select
        event_id,
        user_id,
        event_type,
        revenue,
        to_date(normalized_date, 'DD-MM-YYYY') as date_events
    from clean_date_events_2
),

cohort_table as (
    select
        du.*,
        dv.event_id,
        dv.user_id as event_user_id,
        dv.event_type,
        dv.revenue,
        dv.date_events,

        to_date(
            to_char(du.signup_date_users, 'YYYY-MM'),
            'YYYY-MM'
        ) as cohort_date,

        to_date(
            to_char(dv.date_events, 'YYYY-MM'),
            'YYYY-MM'
        ) as event_month,

        (
            extract(year from dv.date_events) * 12
            + extract(month from dv.date_events)
        )
        -
        (
            extract(year from du.signup_date_users) * 12
            + extract(month from du.signup_date_users)
        ) as month_offset

    from dateset_users du

    left join dateset_events dv
        on du.user_id = dv.user_id

    where du.signup_date_users is not null
        and dv.date_events is not null
        and dv.event_type is not null
        and dv.event_type != 'test_event'
)

select
    promo_signup_flag,
    cohort_date as cohort_month,
    month_offset,
    count(distinct user_id) as users_total

from cohort_table

where date_events between '2025-01-01' and '2025-06-30'

group by 1, 2, 3

order by 1, 2, 3;