--Data preparation
--Let’s restrict our records to visitors from US only. Because we need check each regions of countries in the data cleaning process and code will be so long. 
CREATE OR REPLACE TABLE `scenic-comfort-355914.Traffic.WebSessions`  AS
SELECT parse_date('%Y%m%d',date) Date, TIMESTAMP_SECONDS(VisitStartTime) VisitStartTime, CONCAT(FullVisitorId, CAST(VisitId AS STRING)) UniqueSessionId, 
    FullVisitorId User,VisitId, VisitNumber, TrafficSource.Source, TrafficSource.Medium,
    Device.DeviceCategory Device, Device.OperatingSystem, Device.Browser, ChannelGrouping Channel, Geonetwork.Country Country, Geonetwork.Region State,
    CAST(SUM(IFNULL(Totals.Transactions,0)) AS INTEGER) AS Orders, 
    CAST(SUM(IFNULL(Totals.PageViews,0)) AS INTEGER) AS PageViews, 
    CAST(SUM(IFNULL(Totals.Visits,0)) AS INTEGER) AS Visits, 
    ROUND(SUM(IFNULL(Totals.TimeOnSite, 0))/60,2) AS DurationMinutes, 
    SUM(IFNULL(Totals.TotalTransactionRevenue, 0))/1000000 As Sales  
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE trafficSource.source <> 'mall.googleplex.com'  -- remvoe internal traffic
    AND geoNetwork.country='United States' -- restict data to US only
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
ORDER BY 3;

--Data cleaning

SELECT DISTINCT STATE FROM `scenic-comfort-355914.Traffic.WebSessions` A
WHERE NOT EXISTS (SELECT 1
                  FROM `scenic-comfort-355914.Traffic.USStates` B
                  WHERE B.State_Name = A.State);

--Remove non-US regions

DELETE `scenic-comfort-355914.Traffic.WebSessions` A
WHERE NOT EXISTS (SELECT 1
                  FROM `scenic-comfort-355914.Traffic.USStates` B
                  WHERE B.State_Name = A.State)
                  AND A.State NOT IN ('not available in demo dataset', '(not set)', 'District of Columbia');