open System
open System.IO
open Jeebs // works in LINQPad, waiting for F# 5 so scripts can import NuGet packages



let year = 2021
let path = @"Q:\Work\Personal\Bible\BCG Bible Reading Plan.txt"
let restOnSundays = true
let holidays =
    [ DateRange(DateTime(year, 12, 25)) ]



type Reading =
    { Day : int
      OT1 : string
      OT2 : string
      Gos : string
      Epi : string
      Psa : string }



type Activity = | Rest | Read of Reading



type Day =
    { Date : DateTime
      Activity : Activity }



let getInput =
    match File.Exists path with
    | true -> File.ReadAllLines path |> List.ofArray
    | false -> failwith "Input file not found."



let convertArrayToReading (input : string) =
    let split = input.Split '\t'
    { Day = split.[0] |> int
      OT1 = split.[1]
      OT2 = split.[2]
      Gos = split.[3]
      Epi = split.[4]
      Psa = split.[5] }



let readings =
    getInput
    |> List.map convertArrayToReading



let isHoliday (date : DateTime) =
    holidays
    |> List.fold (fun h d -> h || d.Includes date) false



let restToday (date : DateTime) =
    (restOnSundays && date.DayOfWeek = DayOfWeek.Sunday) || isHoliday date



let getActivity index date =
    match restToday date || index >= readings.Length with
    | true -> Rest
    | false -> Read readings.[index]



let getDates year =
    let startDate, endDate = DateTime(year, 1, 1), DateTime(year, 12, 31)
    let numberOfDays = (endDate - startDate).Days |> float
    [0. .. numberOfDays]
    |> List.map startDate.AddDays



let whatToDo index date =
    let activity = getActivity index date
    { Date = date ; Activity = activity } , match activity with
                                            | Rest -> index
                                            | Read _ -> index + 1



let printDay day =
    if day.Date.Day = 1 then printfn "%s" <| day.Date.ToString("MMMM")
    printf "%s;" <| day.Date.ToString("dd/MM/yy")
    match day.Activity with
    | Rest -> printfn "Holiday"
    | Read r -> printfn "Day %i;Ps %s;%s;%s;%s;%s" r.Day r.Psa r.OT1 r.OT2 r.Gos r.Epi



let dates = getDates year
let allowedRestDays = dates.Length - readings.Length
let actualRestDays = dates |> List.filter restToday |> List.length
let remainingRestDays = allowedRestDays - actualRestDays

if remainingRestDays > 0 then printfn "You have %i additional rest %s to take." remainingRestDays <| "day".Pluralise(remainingRestDays |> float)
match remainingRestDays < 0 with
| true -> printfn "You have entered too many holiday dates - try again."
| false -> dates
           |> List.mapFold whatToDo 0 |> fst
           |> List.iter printDay