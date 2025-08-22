# Terraform MCP Server Setup

## Docker Installation
The Terraform MCP Server is now installed and running via Docker using the official image `hashicorp/terraform-mcp-server:latest`.

## VS Code Integration
A `.vscode/mcp.json` file has been created for seamless integration with VS Code MCP tools:

```
{
  "servers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-p", "8080:8080",
        "-e", "TRANSPORT_MODE=streamable-http",
        "-e", "TRANSPORT_HOST=0.0.0.0",
        "hashicorp/terraform-mcp-server:latest"
      ]
    }
  }
}
```

## Running the Server
The server is started with:

```
docker run -d --rm -p 8080:8080 -e TRANSPORT_MODE=streamable-http -e TRANSPORT_HOST=0.0.0.0 --name terraform-mcp-server hashicorp/terraform-mcp-server:latest
```

## Health Check
To verify the server is running:

```
curl http://localhost:8080/health
```
Should return:
```
{"status":"ok","service":"terraform-mcp-server","transport":"streamable-http","endpoint":"/mcp"}
```

## Troubleshooting
- Ensure Docker is running and accessible.
- If port 8080 is in use, change the port in both the Docker command and `.vscode/mcp.json`.
- For security in production, set `MCP_ALLOWED_ORIGINS` to restrict CORS.

## References
- [Terraform MCP Server GitHub](https://github.com/hashicorp/terraform-mcp-server)
- [VS Code MCP Agent Mode](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
