SELECT TOP 200
    specobjID, plate, mjd, fiberID, z
FROM
    SpecObj
WHERE
    z BETWEEN 2 AND 3
