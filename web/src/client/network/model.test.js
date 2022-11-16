/*
 * Copyright (c) [2022] SUSE LLC
 *
 * All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, contact SUSE LLC.
 *
 * To contact SUSE LLC about this file by physical or electronic mail, you may
 * find current contact information at www.suse.com.
 */

// @ts-check

import { createConnection, createAccessPoint, connectionHumanState } from "./model";

describe("createConnection", () => {
  it("creates a connection with the default values", () => {
    const connection = createConnection({ name: "Wired connection" });
    expect(connection).toEqual({
      id: undefined,
      name: "Wired connection",
      ipv4: {
        method: "auto",
        addresses: [],
        nameServers: [],
        gateway: ""
      }
    });
    expect(connection.wireless).toBeUndefined();
  });

  it("merges given properties", () => {
    const addresses = [{ address: "192.168.0.1", prefix: 24 }];
    const connection = createConnection({ ipv4: { addresses, testing: 1 } });
    expect(connection.ipv4).toEqual({
      method: "auto",
      addresses,
      nameServers: [],
      gateway: ""
    });
  });

  it("adds a wireless key when given", () => {
    const wireless = { ssid: "MY_WIRELESS" };
    const connection = createConnection({ name: "Wireless 1", wireless });
    expect(connection.wireless).toEqual(wireless);
  });
});

describe("createAccessPoint", () => {
  it("creates an AccessPoint using the given values", () => {
    const ap = createAccessPoint({
      ssid: "WIFI1",
      hwAddress: "11:22:33:44:55:66",
      strength: 90,
    });

    expect(ap).toEqual({
      ssid: "WIFI1",
      hwAddress: "11:22:33:44:55:66",
      strength: 90,
      security: []
    });
  });
});

describe("connectionHumanState", () => {
  it("returns a human readable connection state", () => {
    expect(connectionHumanState(0)).toEqual("unknown");
    expect(connectionHumanState(1)).toEqual("activating");
    expect(connectionHumanState(2)).toEqual("activated");
    expect(connectionHumanState(3)).toEqual("deactivating");
    expect(connectionHumanState(4)).toEqual("deactivated");
  });
});
