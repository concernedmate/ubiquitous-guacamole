let map = `
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________
__============__=__==============================_=__============__
__====_=======__=__=============_=_==============_=__====_==_====__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============_____==============================____============__
__============_____==============================____============__
__============_____==============================____============__
__============_____==============================____============__
__=_==========__=__==============================_=__============__
__=_==========__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
________________=__==============================_=________________
________________=__==============================_=________________
________________=__==============================_=________________
________________=__==============================_=________________
__============__=__==============================_=__============__
__====_==_====__=__==============================_=__====_==__===__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=___=============================_=__============__
__============__=___============================__=__============__
__============__=___============================__=__============__
__============______============================_____============__
__============______============================_____============__
_____________________==========================____________________
_____________________==========================____________________
________________=_____========================____=________________
________________=_____========================____=________________
__============__=______======================_____=__============__
__============__=_______====================______=__============__
__=====__=====__=_________________________________=__=====_======__
__============__=_________________________________=__============__
__============__=_________________________________=__============__
__============__=_________________________________=__============__
__============__=__==============================_=__============__
__============__=__=============_================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
__============__=__==============================_=__============__
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________

`

const arr = []
arr.push([])

let idx = 0
for (let i = 0; i < map.length; i++) {
    if (map[i] == '\n') {
        arr.push([])
        idx++
    } else {
        arr[idx].push(map[i])
    }
}

const availableBlock = []
for (let y = 0; y < arr.length; y++) {
    for (let x = 0; x < arr[y].length; x++) {
        if (arr[y][x] == "_") { availableBlock.push({ x, y }) }
    }
}

// pathfinding algorithm
const convTextArr = (map) => {
    const arr = []
    arr.push([])

    let idx = 0
    for (let i = 0; i < map.length; i++) {
        if (map[i] == '\n') {
            arr.push([])
            idx++
        } else {
            arr[idx].push(map[i])
        }
    }
    return arr;
}


let oldPath = []
/**
 * 
 * @param {{x: number, y: number}} curr 
 * @param {{x: number, y: number}} end 
 * @param {{x: number, y: number}[]} path
 * @param {number[][]} arr_map
 * @param {number} idx_difference
 * @returns {1 | 0}
 */
const pathfinding = (curr, start, end, path, arr_map, idx_difference) => {
    path.push(curr)
    oldPath.push(curr)
    if (curr.x == end.x && curr.y == end.y) {
        return path.slice()
    }
    if (curr.y > arr_map.length - 1) {
        return null
    }
    if (arr_map[curr.y] == undefined || curr.x > arr_map[curr.y].length - 1) {
        return null
    }
    if (arr_map[curr.y][curr.x] == '=') {
        return null
    }

    /**
     * @type {{x: number, y: number, cost: number}[]}
     */
    const possibleMoves = []

    if (oldPath.find((val) => { return val.x == curr.x + idx_difference && val.y == curr.y }) == undefined) {
        possibleMoves.push({ x: curr.x + idx_difference, y: curr.y, cost: calculateCost({ x: curr.x + idx_difference, y: curr.y }, start, end) })
    }
    if (oldPath.find((val) => { return val.x == curr.x - idx_difference && val.y == curr.y }) == undefined) {
        possibleMoves.push({ x: curr.x - idx_difference, y: curr.y, cost: calculateCost({ x: curr.x - idx_difference, y: curr.y }, start, end) })
    }
    if (oldPath.find((val) => { return val.x == curr.x && val.y == curr.y + idx_difference }) == undefined) {
        possibleMoves.push({ x: curr.x, y: curr.y + idx_difference, cost: calculateCost({ x: curr.x, y: curr.y + idx_difference }, start, end) })
    }
    if (oldPath.find((val) => { return val.x == curr.x && val.y == curr.y - idx_difference }) == undefined) {
        possibleMoves.push({ x: curr.x, y: curr.y - idx_difference, cost: calculateCost({ x: curr.x, y: curr.y - idx_difference }, start, end) })
    }

    possibleMoves.sort((a, b) => { return a.cost - b.cost })
    for (let i = 0; i < possibleMoves.length; i++) {
        let result = pathfinding({ x: possibleMoves[i].x, y: possibleMoves[i].y }, start, end, path.slice(), arr_map, idx_difference)
        if (result != null) {
            oldPath = []
            return result
        }
    }
    return null
}

/**
 * 
 * @param {{x: number, y: number}} curr 
 * @param {{x: number, y: number}} start 
 * @param {{x: number, y: number}} end 
 * @returns {number}
 */
const calculateCost = (curr, start, end) => {
    const distance = Math.abs(curr.x - start.x) + Math.abs(curr.y - start.y)
    const heuristic = ((curr.x - end.x) * (curr.x - end.x)) + ((curr.y - end.y) * (curr.y - end.y)) // simple distance
    return distance + heuristic
}

/**
 * 
 * @param {{x: number, y:number}[]} path 
 * @param {number} idx_difference 
 */
const trimPath = (path, idx_difference = 1) => {
    if (path == undefined) { return [] }
    const trimmed = []
    let i = 0
    while (i < path.length) {
        let available = []
        available.push(i)
        available.push(path.findIndex((val) => { return val.x == path[i].x + idx_difference && val.y == path[i].y }, i))
        available.push(path.findIndex((val) => { return val.x == path[i].x - idx_difference && val.y == path[i].y }, i))
        available.push(path.findIndex((val) => { return val.x == path[i].x && val.y == path[i].y + idx_difference }, i))
        available.push(path.findIndex((val) => { return val.x == path[i].x && val.y == path[i].y - idx_difference }, i))
        available.sort((a, b) => { return b - a })
        trimmed.push(path[available[0]])
        if (i != available[0]) {
            i = available[0]
        } else {
            i++
        }
    }
    return trimmed
}

// PRINT MAP AND SOLUTION

const randS = availableBlock[Math.floor(Math.random() * availableBlock.length)];
const randE = availableBlock[Math.floor(Math.random() * availableBlock.length)];

let start = { x: randS.x, y: randS.y }
let end = { x: randE.x, y: randE.y }

for (let y = 0; y < arr.length; y++) {
    let str = ""
    for (let x = 0; x < arr[y].length; x++) {
        if (x == start.x && y == start.y) {
            arr[y][x] = 'S'
        }
        if (x == end.x && y == end.y) {
            arr[y][x] = 'E'
        }
        // if (arr[y][x] == 'S') {
        //     start = { x: x, y: y }
        // }
        // if (arr[y][x] == 'E') {
        //     end = { x: x, y: y }
        // }
        str += arr[y][x]
    }
}
if (start.x != end.x || start.y != end.y) {
    let found
    try {
        found = pathfinding(start, start, end, [], arr, 1)
        let trimmed = trimPath(found)
        console.log("trimmed: ")
        for (let y = 0; y < arr.length; y++) {
            let str = ""
            for (let x = 0; x < arr[y].length; x++) {
                if ((trimmed.find((val) => { return val.x == x && val.y == y }) == undefined || arr[y][x] == 'S' || arr[y][x] == 'E')) {
                    str += arr[y][x]
                } else {
                    str += '*'
                }
            }
            console.log(str)
        }

        if (found == null) {
            console.log("No path available")
        }
        console.log(start, end)
    } catch (error) {
        for (let y = 0; y < arr.length; y++) {
            let str = ""
            for (let x = 0; x < arr[y].length; x++) {
                if ((oldPath.find((val) => { return val.x == x && val.y == y }) == undefined || arr[y][x] == 'S' || arr[y][x] == 'E')) {
                    str += arr[y][x]
                } else {
                    str += '*'
                }
            }
            console.log(str)
        }
    }
}