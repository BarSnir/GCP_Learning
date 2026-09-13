import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class Main {

    public static void main(String[] args) throws IOException {

        int port = Integer.parseInt(
                System.getenv().getOrDefault("PORT", "8080")
        );

        HttpServer server = HttpServer.create(
                new InetSocketAddress(port),
                0
        );

        server.createContext("/", exchange -> {
            String response = "Hello from Java App Engine Standard - V2";

            exchange.sendResponseHeaders(
                    200,
                    response.getBytes().length
            );

            try (OutputStream os = exchange.getResponseBody()) {
                os.write(response.getBytes());
            }
        });

        server.start();

        System.out.println("Server started on port " + port);
    }
}