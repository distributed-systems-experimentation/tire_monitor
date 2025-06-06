use futures::SinkExt;
use tire_monitor_messages::{TirePressureMessage, TireVariant};
use tokio::net::UdpSocket;
use tokio::signal::unix::{SignalKind, signal};
use tokio_util::codec::BytesCodec;
use tokio_util::udp::UdpFramed;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Bind to an address
    let socket = UdpSocket::bind("0.0.0.0:8080").await?;
    socket.set_broadcast(true)?;

    let mut framed = UdpFramed::new(socket, BytesCodec::new());

    let broadcast_addr = "255.255.255.255:8080".parse()?;

    println!("Server listening on 0.0.0.0:8080");

    let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(1));

    let mut sigterm = signal(SignalKind::terminate()).unwrap();

    // Spawn a task for the main loop
    let main_loop = tokio::spawn(async move {
        loop {
            interval.tick().await;

            let message = TirePressureMessage {
                tire_variant: TireVariant::FrontLeft,
                pressure: 32.0,
            };

            println!("Sending {:?}", &message);

            let message = bytes::Bytes::from(
                bincode::encode_to_vec(&message, bincode::config::standard()).unwrap(),
            ); // Using unwrap here for simplicity, proper error handling might be needed

            if let Err(e) = framed.send((message, broadcast_addr)).await {
                eprintln!("Failed to send message: {}", e);
                break; // Exit loop on send error
            }
        }
    });

    // Wait for either the main loop to finish or SIGINT
    tokio::select! {
        _ = main_loop => {
            println!("Main loop finished.");
        }
        _ = sigterm.recv() => {
            println!("SIGTERM received, shutting down.");
        }
    }

    println!("Server shutting down.");

    Ok(())
}
