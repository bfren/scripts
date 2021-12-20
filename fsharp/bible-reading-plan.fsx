#r "nuget: Jeebs"

open System.IO
open Jeebs


let year = 2021
let path = @"Q:\Work\Personal\Bible\BCG Bible Reading Plan.txt"
let restOnSundays = true
let holidays =
    [| DateRange ( DateTime(year, 12, 25) ) |]


type Reading =
    { Day : int
      Psa : string
      OT1 : string
      OT2 : string
      Gos : string
      Epi : string }


type Activity = 
    | Rest 
    | Read of Reading


type Day =
    { Date : DateTime ; 
      Activity : Activity }


let convertArrayToReading (input : string) =
    let parts = input.Split '\t'
    { Day = parts[0] |> int
      Psa = parts[1]
      OT1 = parts[2]
      OT2 = parts[3]
      Gos = parts[4]
      Epi = parts[5] }


let readings =
    match File.Exists path with
    | false -> failwith "Input file not found."
    | true -> File.ReadAllLines path |> Array.map convertArrayToReading


let isRestDay (date : DateTime) =
    let isHoliday () = holidays |> Array.fold (fun h d -> h || d.Includes date) false
    (restOnSundays && date.DayOfWeek = DayOfWeek.Sunday) || isHoliday()


let getActivity index date =
    match isRestDay date || index >= readings.Length with
    | true -> Rest
    | false -> Read readings[index]


let whatToDo index date =
    let activity = getActivity index date
    { Date = date ; Activity = activity } , match activity with | Rest -> index | Read _ -> index + 1


let getDates year =
    let startDate, endDate = DateTime(year, 1, 1), DateTime(year, 12, 31)
    let range = endDate - startDate
    let numberOfDays = range.Days |> float
    [0. .. numberOfDays] |> List.map startDate.AddDays


let printDay day =
    if day.Date.Day = 1 then printfn "%s" <| day.Date.ToString "MMMM"
    printf "%s;" <| day.Date.ToString "dd/MM/yy"
    match day.Activity with
    | Rest -> printfn "Rest"
    | Read r -> printfn "Day %i;Ps %s;%s;%s;%s;%s" r.Day r.Psa r.OT1 r.OT2 r.Gos r.Epi


let dates = getDates year
let allowedRestDays = dates.Length - readings.Length
let actualRestDays = dates |> List.filter isRestDay
let remainingRestDays = allowedRestDays - actualRestDays.Length |> int64

match remainingRestDays with
| days when days < 0L -> 
    printfn "You have asked for too many rest days - please try again."
| days -> 
    printfn "You have %i additional rest %s to take." days ("day".Pluralise days)
    dates
    |> List.mapFold whatToDo 0 |> fst
    |> List.iter printDay
