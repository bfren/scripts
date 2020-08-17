open System.Net.Http
open System.Net.Http.Headers
open Jeebs.Static
open Newtonsoft.Json


let passages = [
    (BibleBooks.Galatians, "1")
    (BibleBooks.Galatians, "2")
    (BibleBooks.Galatians, "3")
    ]


type Response =
	{ Query: string
	  Canonical : string
	  Passages : string list }
      
      
let split (result : Response * string[] option) =
    match result with
    | Some response, passage -> Regex.Split(passage, @"\W", RegexOptions.IgnoreCase)
                                 |> response, Array.filter (fun w -> not(String.IsNullOrEmpty(w)))
    | None -> [| |]
    
    
let get response =
    match response.Passages.Length with
    | 1 -> Some(response, response.Passages.Single())
    | _ -> None


let deserialise content =
	JsonConvert.DeserializeObject<Response>(content)


let read (response : HttpResponseMessage) =
   async {
	    let message = response.EnsureSuccessStatusCode()
		return! message.Content.ReadAsStringAsync() |> Async.AwaitTask
	} |> Async.RunSynchronously


let send request =
	async {
	    let client = new HttpClient()
		return! request |> client.SendAsync |> Async.AwaitTask
    } |> Async.RunSynchronously


let build (url : string) =
    let request = new HttpRequestMessage(HttpMethod.Get, url)
	let apiKey = "dec9ec59e42cf5ba7348961ec347d7ee457fa3ab"
	request.Headers.Authorization <- AuthenticationHeaderValue("Token", apiKey)
	request


let getUrl (ref : string * string) =
    let book, passage = ref
    let ref = (sprintf "%s %s" book passage).Replace(' ', '+')
    ref |> sprintf "https://api.esv.org/v3/passage/text/?q=%s&include-passage-references=false&include-verse-numbers=false&include-first-verse-numbers=false&include-footnotes=false&include-headings=false&include-short-copyright=false&include-selahs=false"


let run = List.map getUrl >> build >> send >> read >> deserialise >> get >> split


let output 



passages
|> List.map run
|> printfn "%O"
