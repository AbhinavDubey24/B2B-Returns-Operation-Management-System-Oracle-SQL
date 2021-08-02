-- TEAM 13 Phase 3 SQL File

-- REPORT 1

--Purpose: Make an overall month on month dashboard for company's leadership

--Benefit: Helps track historical and current business performance. Also helps 
--in predicting month end numbers and serves as data for planning into the future

--Use in business: Helps in tracking business performance. Can help in pointing 
--our problems within the return process.Returns approved, rejected, and those 
--not terminated gives a view of overall return performance. It also showcases 
--where the bottleneck in the system might be. Too many rejected returns can 
--lead to poor customer overview, whereas too less rejected returns can mean 
--angry sellers and a poor profit/loss performance.

-- SQL Code:

select to_char(r13.return_date,'fmMonth YYYY') as Months, 
       count(distinct(r13.return_id)) as "Total returns raised", 
       sum(decode(r13.return_status,'RETURN_APPROVED',1,0)) as "Returns Approved",
       sum(decode(r13.return_status,'RETURN_REJECTED',1,0)) as "Returns Rejected",
       sum(case when r13.return_status not in ('RETURN_APPROVED', 'RETURN_REJECTED') then 1 else 0 end) as "Other Returns"
from prp20002.return13 r13
group by to_char(r13.return_date,'fmMonth YYYY')
order by substr(to_char(r13.return_date,'fmMonth YYYY'),-4,4), 
        (case when to_char(r13.return_date,'fmMonth YYYY') like 'Jan%' then 1
              when to_char(r13.return_date,'fmMonth YYYY') like 'Feb%' then 2
              when to_char(r13.return_date,'fmMonth YYYY') like 'Mar%' then 3
              when to_char(r13.return_date,'fmMonth YYYY') like 'Apr%' then 4
              when to_char(r13.return_date,'fmMonth YYYY') like 'May%' then 5
              when to_char(r13.return_date,'fmMonth YYYY') like 'Jun%' then 6
              when to_char(r13.return_date,'fmMonth YYYY') like 'Jul%' then 7
              when to_char(r13.return_date,'fmMonth YYYY') like 'Aug%' then 8
              when to_char(r13.return_date,'fmMonth YYYY') like 'Sep%' then 9
              when to_char(r13.return_date,'fmMonth YYYY') like 'Oct%' then 10
              when to_char(r13.return_date,'fmMonth YYYY') like 'Nov%' then 11
              when to_char(r13.return_date,'fmMonth YYYY') like 'Dec%' then 12 end);
              
-- REPORT 2

-- Purpose: Incentivize customers for better return performance

-- Benefit: Customer retention and promoting better buyers to spend more on 
-- platform

-- Use in Business: Customers with less returns leads to a better profit and loss statement for the company. In lieu of this, the company is incentivizing customers with better behavior by offering them more discounts and ensuring they retain the business with them. This analysis can also be used to show customers how far they are from their tier and to educate them on better return practices.

-- SQL Code:

select o.customer_id, sum(o.order_amt) order_amt, decode(r.return_amt, null, 0, r.return_amt) as Ret_amt, decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt) as PRTO_ret_amt,
     (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) as total_return,
     case 
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) < 1000
            then '10%'
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) between 1000 and 5000
            then '5%'
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) between 5000 and 10000
            then '2%'
        else '0%'
    end as "Discount on Next Order"
    
from prp20002.order13 o
left join (select r.customer_id, sum(rl.return_line_amount) as return_amt
           from prp20002.return_line rl
           left join prp20002.return13 r on r.return_id = rl.return_id
           group by r.customer_id) r on
    r.customer_id = o.customer_id
left join (select o.customer_id, sum(pro.partial_rto_ret_amt) as PRTO_return_amt
           from prp20002.partial_rto_order pro
           left join prp20002.order13 o on o.order_id = pro.order_id
           group by o.customer_id) p on
    p.customer_id = o.customer_id
    
group by 
    o.customer_id, decode(r.return_amt, null, 0, r.return_amt), decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt),
    (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)),
    case 
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) < 1000
            then '10%'
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) between 1000 and 5000
            then '5%'
        when (decode(r.return_amt, null, 0, r.return_amt) + decode(p.PRTO_return_amt, null, 0, p.PRTO_return_amt)) between 5000 and 10000
            then '2%'
        else '0%'
    end
order by o.customer_id;                                                                                                                                                                         

-- REPORT 3

-- Purpose: Seller dashboard 

-- Benefit: Can be used to monitor seller performance

-- Use in business: This can be used to track and measure seller's returns performance. A seller with high return can be detrimental to the business. Catching such a seller behavior early is beneficial to the business. This can also be used to incentivize sellers in the future and decide if we need to part ways with a seller or not.

-- SQL Code:

SELECT s.seller_id
    , temp.amt "Order_Amount"
    , CASE WHEN temp.return_status = 'RETURN_APPROVED' THEN temp.ret_amt else 0 END "Returns_Approved"
    , CASE WHEN temp.return_status = 'RETURN_REJECTED' THEN temp.ret_amt else 0 END "Returns_Rejected"
    , CASE WHEN temp.return_status = 'RETURN_COMPLETE' THEN temp.ret_amt else 0 END "Refunded"
    , CASE WHEN temp.return_status = 'RETURN_LOST' THEN temp.ret_amt else 0 END "Returns_Lost"
    , CASE WHEN temp.return_status = 'RETURN_RVP_ABSORBED' THEN temp.ret_amt else 0 END "Returns Logistics Issue"
    , CASE WHEN temp.return_status = 'RETURN_IN_TRANSIT' THEN temp.ret_amt else 0 END "Returns_In_Transit"
FROM prp20002.seller s
LEFT JOIN (SELECT distinct o.seller_id, r13.return_status, SUM(o.order_amt) amt, SUM(rl.return_line_amount) ret_amt
            FROM prp20002.order13 o
            LEFT JOIN prp20002.order_line ol on o.order_id = ol.order_id
            LEFT JOIN prp20002.return_line rl on rl.order_line_id = ol.order_line_id
            LEFT JOIN prp20002.return13 r13 on r13.return_id = rl.return_id
            GROUP BY o.seller_id, r13.return_status ) temp
            ON temp.seller_id = s.seller_id
ORDER BY "Returns_Approved" DESC; 


-- REPORT 4

-- Purpose: Customer perception of return as time taken to complete increases

-- Benefit: Derive insights to improve business performance

-- Use in Business : Gives an aim for the timeline to target to complete a return to increase customer satisfaction. A better return experience increases customer engagement and trust with the platform and promotes healthy return behavior.

-- SQL Code:

SELECT CASE WHEN temp.ndays < 3 THEN '0 to 2 days' 
            WHEN temp.ndays < 5 AND temp.ndays > 2 THEN '3 to 5 days'
            WHEN temp.ndays < 7 AND temp.ndays > 3 THEN '4 to 6 days'
            WHEN temp.ndays < 9 AND temp.ndays > 5 THEN '6 to 8 days'
            WHEN temp.ndays < 11 AND temp.ndays > 8 THEN '8 to 10 days'
            WHEN temp.ndays > 10 THEN 'More than 10 days' END "Number_of_Days"
    , AVG(temp.review_rating) "average_review_rating"
FROM prp20002.return13 r13
LEFT JOIN (SELECT rst.return_id, (rst.new_status_timestamp - r.return_date) ndays, r.review_rating
            FROM PRP20002.return_state_transition rst
            LEFT JOIN PRP20002.return13 r
            ON r.return_id = rst.return_id
            WHERE rst.current_active = 1) temp ON r13.return_id = temp.return_id
WHERE r13.return_status = 'RETURN_COMPLETE' or r13.return_status = 'RETURN_APPROVED'
GROUP BY CASE WHEN temp.ndays < 3 THEN '0 to 2 days' 
                WHEN temp.ndays < 5 AND temp.ndays > 2 THEN '3 to 5 days' 
                WHEN temp.ndays < 7 AND temp.ndays > 3 THEN '4 to 6 days' 
                WHEN temp.ndays < 9 AND temp.ndays > 5 THEN '6 to 8 days' 
                WHEN temp.ndays < 11 AND temp.ndays > 8 THEN '8 to 10 days' 
                WHEN temp.ndays > 10 THEN 'More than 10 days' END;
                
-- REPORT 5

-- Purpose: Test performance for the added feature

-- Benefit: Partial RTO helps to avoid additional or repetitive logistics cost and helps us deliver more when instead a return would have happened

-- Use in Business: In case the buyer doesn't want the complete order, and the cost for taking the order back to warehouse is significant due to B2B market, a partial invoice is generated and the customer can keep the part of the order they like. This helps deliver more product and make sure of the already invested logistics cost for that particular order.

-- SQL Code:

SELECT o13.seller_id
    , SUM(CASE WHEN o13.order_status = 'ORDER_DELIVERED' THEN o13.order_amt ELSE 0 END) "Delivered_Value"
    , SUM(CASE WHEN o13.order_status = 'ORDER_PARTIAL_RTO' THEN temp.e_amt ELSE 0 END) "Partially_or_Extra_Delivered"
FROM prp20002.order13 o13
LEFT JOIN (SELECT pro.order_id, SUM(pro.partial_rto_del_amt) e_amt
            FROM PRP20002.partial_rto_order pro
            GROUP BY pro.order_id) temp ON temp.order_id = o13.order_id
GROUP BY o13.seller_id;

