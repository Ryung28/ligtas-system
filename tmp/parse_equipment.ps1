
$content = Get-Content "d:\LIGTAS_SYSTEM\newequipmentlist.txt"
$items = @()

function Get-Category($name) {
    if ($name -match "Oxygen|Bandage|Stethoscope|Nebulizer|Glucometer|Pulse|Oximeter|Sphygmomanometer|BP|Raphael|Asclepius|First Aid") { return "Medical" }
    if ($name -match "Snake|Life vest|Life Jacket|Throw Bag|Life Bouy|Life Can|Scuba|Rope|Carabiner|Crowbar|Axe|Shovel|Sledge|Jack Hammer|Tagad|Piko|Dibble|Mattack|Crocodile Jack|Hook|Grab|Can|Vest|Ring") { return "Rescue" }
    if ($name -match "Fan|Projector|Speaker|HDMI|Microphone|Table|Bed|Chairs|Megaphone|Display|Screen|Paper Cutter|Foot Pump|Scale") { return "Logistics" }
    if ($name -match "Helmet|Boots|Coller") { return "PPE" }
    if ($name -match "Battery Charger|Hand Drill|Drill Bit|Chainsaw") { return "Tools" }
    return "Others"
}

foreach ($line in $content) {
    # Remove leading number and colon if exists
    $cleanLine = $line -replace "^\d+:\s*", ""
    if ([string]::IsNullOrWhiteSpace($cleanLine)) { continue }

    # Split by comma or & or "and"
    $parts = $cleanLine -split '[,&]| and '
    
    foreach ($part in $parts) {
        $trimmedPart = $part.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmedPart)) { continue }

        $qty = 1
        $name = $trimmedPart

        # Extract number at the start
        if ($trimmedPart -match "^(\d+)\s+(.+)") {
            $qty = [int]$matches[1]
            $name = $matches[2]
        }

        $items += [PSCustomObject]@{
            Name = $name
            Qty = $qty
            Category = Get-Category $name
        }
    }
}

# Aggregate by Name and Category
$aggregated = $items | Group-Object Name, Category | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Values[0]
        Category = $_.Values[1]
        Qty = ($_.Group | Measure-Object Qty -Sum).Sum
    }
}

$sql = @"
-- ============================================================================
-- LIGTAS SYSTEM - BULK INVENTORY REPLACEMENT
-- ============================================================================
-- 1. CLEAR OLD DATA
TRUNCATE TABLE borrow_logs, inventory RESTART IDENTITY CASCADE;

-- 2. INSERT NEW DATA
INSERT INTO inventory (item_name, category, stock_total, stock_available, status) VALUES
"@

foreach ($item in $aggregated) {
    $name = $item.Name.Replace("'", "''")
    $category = $item.Category
    $qty = $item.Qty
    $sql += "`n('$name', '$category', $qty, $qty, 'Good'),"
}

# Remove trailing comma and add semicolon
$sql = $sql.TrimEnd(',') + ";"

$sql | Out-File "d:\LIGTAS_SYSTEM\web\_db_scripts\REPLACE_INVENTORY_NEW_LIST.sql" -Encoding utf8
Write-Host "SQL script generated successfully."
