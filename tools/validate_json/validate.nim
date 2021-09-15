import json
import sequtils
import strformat

const JSON_FOLDER = "../../SPQR2/data/"
const GAME_DATA = "game_data.json"

type Region = object
    name: string
    city: string
    city_pos: array[0..1, int]
    culture: int
    wealth: int
    manpower: int
    loyalty: int
    color: array[0..2, int]
    id: int

proc error(message: string): void =
    echo &"* Error: {message}"
    quit(QuitFailure)

proc validateRegion(region: Region): void =
    # ensure all strings are non-empty
    if(region.name.len == 0):
        error("Region name is empty string")
    if(region.city.len == 0):
        error("City name is empty string")
    # and color is in range
    for i in region.color:
        if(i < 0 or i > 255):
            error(&"Index {i} in color is invalid")

proc checkNonZeroRegions(regions: seq[Region]): void =
    if(regions.len == 0):
        error("No regions set")

proc checkAllPaths(paths: JsonNode, name: string): seq[int] =
    # must be an array of some kind
    if(paths.kind != JArray):
        error(&"{name} paths is not an array")
    # each of the elements inside is also a 2 index array containing ints only
    var indexes: seq[int] = @[]
    for i in getElems(paths):
        if(i.kind != JArray):
            error("A path must be an array")
        if(i.getElems().len != 2):
            error("All paths must of length 2")
        for j in i.getElems():
            if(j.kind != JInt):
                error("All path entries must be integers")
            indexes.add(getInt(j))
    return indexes

proc verifyPathIndexes(values: seq[int], regions: seq[Region]): void = 
    var uniques = deduplicate(values)
    # go through all regions
    var rid: seq[int] = @[]
    for i in regions:
        rid.add(i.id)
    # confirm all path indexes exist
    for i in uniques:
        if(count(rid, i) == 0):
            error(&"Index {i} does not exisr in regions")

proc checkGameData(): void =
    var filename = JSON_FOLDER & GAME_DATA
    echo &"* Checking {filename}"
    var js_data = parseFile(filename)
    var regions: seq[Region] = @[]
    for i in js_data["REGIONS"]:
        regions.add(to(i, Region))
        validateRegion(regions[regions.high])
    var all_path_indexes: seq[int] = @[]
    all_path_indexes = checkAllPaths(js_data["PATHS"]["LAND"], "Land") & all_path_indexes
    all_path_indexes = checkAllPaths(js_data["PATHS"]["LAND"], "Sea") & all_path_indexes
    checkNonZeroRegions(regions)
    verifyPathIndexes(all_path_indexes, regions)

when isMainModule:
    try:
        checkGameData()
    except:
        error("Closing")
    echo "* Game Data OK"
