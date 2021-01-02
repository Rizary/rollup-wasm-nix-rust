use std::rc::Rc;
use std::cell::Cell;

use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::{JsFuture, spawn_local};
use wasm_bindgen::JsCast;
use wasm_bindgen::JsValue;

use futures_signals::signal::{Signal, SignalExt, Mutable};
use futures_signals::signal_vec::{SignalVec, SignalVecExt, MutableVec};
use dominator::{Dom, text_signal, html, clone, events, link};

use js_sys::Error;
use web_sys::{window, Response, RequestInit, Headers, RequestMode};

use crate::routing::Route;

#[derive(Debug)]
pub struct App {

    message: Mutable<String>,

}

const BASE_URL: &str = "http://localhost:8185";

impl App {
    pub fn new() -> Rc<Self> {
        Rc::new(App {
            message: Mutable::new("".to_owned()),
        })
    }

    pub async fn deserialize() -> Rc<Self> {
        let app =  App::new();
        app
    }

    fn render_header(app: Rc<Self>) -> Dom {
        html!("header", {
            .class(["header","m-6","d-inline-flex","flex-row","width-auto","flex-justify-between","flex-wrap"])
            .children(&mut [
                html!("h1", {
                    .class(["h1","m-6","p-6","text-bold","text-center","my-lg-2","width-full"])
                    .text("Hi")
                }),

                html!("input", {
                    .focused(true)
                    .class(["new-todo","form-control","width-full"])
                    .attribute("placeholder", "What needs to be done?")
                    .property_signal("value", app.message.signal_cloned())
                }),
            ])
        })
    }

    fn render_main(app: Rc<Self>) -> Dom {
        html!("section", {
            .class(["main","my-2","mx-6","d-inline-flex","flex-column"])
            // Hide if it doesn't have any todos.

            .children(&mut [
                html!("div", {
                    .class(["d-inline-flex","flex-row","flex-items-center"])
                }),
            ])
        })
    }

    fn render_button(text: &str, route: Route) -> Dom {
        html!("li", {
            .children(&mut [
                link!(route.url(), {
                    .text(text)
                    .class_signal("selected", Route::signal().map(move |x| x == route))
                })
            ])
        })
    }

    fn render_footer(app: Rc<Self>) -> Dom {
        html!("footer", {
            .class(["footer","p-2","my-2","mx-6","d-inline-flex","flex-column"])
            // Hide if it doesn't have any todos.
        })
    }

    pub fn render(app: Rc<Self>) -> Dom {
        html!("section", {
            .class(["todoapp","bg-gray-light","height-full","d-inline-flex","flex-column","width-full"])
            .children(&mut [
                Self::render_header(app.clone()),
                Self::render_main(app.clone()),
                Self::render_footer(app.clone()),
            ])
        })
    }
}

#[inline]
pub fn trim(input: &str) -> Option<String> {
    let trimmed = input.trim();

    if trimmed.is_empty() {
        None

    } else {
        Some(trimmed.to_owned())
    }
}
