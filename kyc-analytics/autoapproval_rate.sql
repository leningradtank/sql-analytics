WITH auto_app AS (
    SELECT account_status.at, account_status.account_id AS auto_approved_acc, account_details.country_of_tax_residence, accounts.account
    FROM accounts
    JOIN account_status ON accounts.id::text = account_status.account_id::text
    JOIN account_owners ON accounts.id::text = account_owners.account_id::text
    JOIN account_details ON account_details.owner_id::text = account_owners.owner_id::text
    WHERE account_status.status_from = 'SUBMITTED' 
    AND account_status.status_to = 'APPROVED'
    -- AND account_details.approved_at IS NULL AND account_details.approved_by IS NULL
    AND account_status.account NOT IN ('TYPEA', '')
    AND account_status.account IN (SELECT account FROM accounts WHERE status IN ('live', 'limited') AND kyc_setup->>'type' = 'kycaas')
    and country_of_tax_residence != 'USA'
    GROUP BY 1, 2, 3, 4),
    
    total_acc AS (
    SELECT account_status.at, account_status.account_id AS account_id, account_details.country_of_tax_residence, status_to AS milestone, accounts.account
    FROM accounts
    JOIN account_status ON accounts.id::text = account_status.account_id::text
    JOIN account_owners ON accounts.id::text = account_owners.account_id::text
    JOIN account_details ON account_details.owner_id::text = account_owners.owner_id::text
    WHERE account_status.account NOT IN ('TYPEA', '')
    AND account_status.account IN (SELECT account FROM accounts WHERE status IN ('live', 'limited') AND kyc_setup->>'type' = 'kycaas')
    AND account_status.status_to IN ('SUBMITTED', 'ONFIDO_SUBMITTED')
    and country_of_tax_residence != 'USA'
    GROUP BY 1, 2, 3, 4, 5),
    
    not_sub_status AS (
    SELECT account_status.account_id, status_to AS milestone, at, country_of_tax_residence, accounts.account
    FROM account_status
    JOIN accounts ON accounts.id = account_status.account_id
    JOIN account_owners ON accounts.id = account_owners.account_id
    JOIN account_details ON account_details.owner_id::uuid = account_owners.owner_id::uuid
    WHERE account_status.status_to NOT IN ('SUBMITTED','ONFIDO_SUBMITTED')  -- Check
    AND account_status.account NOT IN ('TYPEA','')
    AND account_status.account IN (SELECT account FROM accounts WHERE status IN ('live', 'limited') AND kyc_setup->>'type' = 'kycaas') 
    and country_of_tax_residence != 'USA'
    GROUP BY 1, 2, 3, 4, 5)
    
SELECT  DATE_TRUNC('week', total_acc.at) AS week_sub,
        total_acc.account,
        COUNT(DISTINCT auto_app.auto_approved_acc) / NULLIF(COUNT(DISTINCT total_acc.account_id),0)::float AS "Auto-approved Rate International Accounts",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'APPROVED' THEN not_sub_status.account_id END) / NULLIF(COUNT(DISTINCT CASE WHEN total_acc.milestone IN ('SUBMITTED', 'ONFIDO_SUBMITTED') THEN total_acc.account_id END),0)::float AS "Approval Rate International Accounts",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'REJECTED' THEN not_sub_status.account_id END) / NULLIF(COUNT(DISTINCT CASE WHEN total_acc.milestone IN ('SUBMITTED', 'ONFIDO_SUBMITTED')  THEN total_acc.account_id END),0)::float AS "Rejection Rate International Accounts",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'ACTION_REQUIRED' THEN not_sub_status.account_id END) / NULLIF(COUNT(DISTINCT CASE WHEN total_acc.milestone IN ('SUBMITTED', 'ONFIDO_SUBMITTED') THEN total_acc.account_id END),0)::float AS "Action Required Rate International Accounts",
        COUNT(DISTINCT total_acc.account_id) AS "International Accounts Submitted",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'ONBOARDING' THEN not_sub_status.account_id END) AS "Onboarding Accounts", 
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'ACTION_REQUIRED'  THEN not_sub_status.account_id END) AS "Action Required Accounts",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'REJECTED' THEN not_sub_status.account_id END) AS "Rejected Accounts",
        COUNT(DISTINCT CASE WHEN not_sub_status.milestone = 'ACTIVE' THEN not_sub_status.account_id END) AS "Active Accounts"
FROM total_acc
LEFT JOIN auto_app ON auto_app.auto_approved_acc = total_acc.account_id
LEFT JOIN not_sub_status ON not_sub_status.account_id = total_acc.account_id
WHERE DATE_TRUNC('week', total_acc.at) >= DATE_TRUNC('month', current_date - interval '3 months')
GROUP BY DATE_TRUNC('week', total_acc.at), total_acc.account
ORDER BY 2 desc;