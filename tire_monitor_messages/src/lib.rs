use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Encode, Decode)]
pub enum TireVariant {
    FrontLeft,
    FrontRight,
    RearLeft,
    RearRight,
}

#[derive(Serialize, Deserialize, Debug, Encode, Decode)]
pub struct TirePressureMessage {
    pub pressure: f64,
    pub tire_variant: TireVariant,
}

#[derive(Serialize, Deserialize, Debug, Encode, Decode)]
pub struct TireTemperatureMessage {
    pub temperature: f64,
    pub tire_variant: TireVariant,
}
