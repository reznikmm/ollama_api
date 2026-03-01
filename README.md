begin

# Ollama API

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/ollama_api.json)](https://alire.ada.dev/crates/ollama_api.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/ollama_api)](https://api.reuse.software/info/github.com/reznikmm/ollama_api)

> Ada library for interacting with the Ollama API, including chat
> and tool support.

This project provides an Ada library for accessing the Ollama API,
enabling chat-based AI interactions and tool integration.
It includes a demo application and is distributed as an Alire crate.

## Features

- **Ollama API Client in Ada**
- **Chat message generation**
- **Tool integration and registration**
- **Custom HTTP request handler support**
- **JSON-based communication**
- **Demo application included**
- **Exception-free operation**

**Limitation**:
- Embedding request is not currently supported.
- Streaming is not implemented yet.

## Repository Structure

- `source/` — Main library sources
- `demos/` — Demo project using the library
- `config/` — Configuration and build files
- `alire.toml` — Alire crate manifest
- `LICENSES/` — License information

## Installation

To install the library using the Alire package manager:

```sh
alr with ollama_api --use=https://github.com/reznikmm/ollama_api.git
```

## Usage Example

Here is a minimal example of using the Ollama API library in Ada:

```ada
declare
   Server   : Ollama_API.Server;
   Response : Ollama_API.Types.ChatResponse;
   Success  : Boolean;
begin
   Server.Set_Request_Handler (HTTP'Unchecked_Access);

   Ollama_API.Chats.Chat
     (Server,
      Model      => "llama3.1:8b",
      Messages   =>
        [(role     => Ollama_API.Types.user,
          content  => "Why Ada is so popular?",
          others   => <>)];
      Tools      => [],
      Stream     => False,
      Keep_Alive => "15m",
      Response   => Response,
      Success    => Ok);

   -- Handle the response
   if Success then
      -- Process Response
   end if;
end;
```

See the `demos/` folder for a complete working example, including tool registration and custom HTTP requests.

## Demos

The `demos` folder contains a sample application demonstrating:
- Registering and using tools (see `concat_tools.ads`)
- Making chat requests
- Handling responses and tool calls

To build and run the demo:

```sh
cd demos
alr build
./bin/demos
```

## Maintainer

Max Reznik <reznikmm@gmail.com>

## License

MIT OR Apache-2.0 WITH LLVM-exception
