use wasm_bindgen::prelude::*;
use web_sys::Url;
use futures_signals::signal::{Signal, SignalExt};
use dominator::routing;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Route {
    // NotFound,
    About,
    Contact,
    Home,
}

impl Route {
    pub fn signal() -> impl Signal<Item = Self> {
        routing::url()
            .signal_ref(|url| Url::new(&url).unwrap_throw())
            .map(|url| {
                match url.hash().as_str() {
                    "#/about" => Route::About,
                    "#/contact" => Route::Contact,
                    _ => Route::Home,
                }
            })
    }

    pub fn url(&self) -> &'static str {
        match self {
            Route::About => "#/about",
            Route::Contact => "#/contact",
            Route::Home => "/",
        }
    }
}
